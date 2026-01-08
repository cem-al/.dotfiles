local wezterm = require "wezterm"
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

-- Enable periodic saving every 15 minutes
resurrect.state_manager.periodic_save()

-- Track which panes we've cleared attention for
local cleared_panes = {}

-- Generate a consistent colour from a string
local function hash_to_color(str, lightness)
    local hash = 0
    for i = 1, #str do
        hash = (hash * 31 + string.byte(str, i)) % 360
    end
    -- Use HSL with fixed saturation, configurable lightness
    local h = hash / 360
    local s = 0.6
    local l = lightness or 0.6
    -- HSL to RGB conversion
    local function hue_to_rgb(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
    end
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    local r = math.floor(hue_to_rgb(p, q, h + 1/3) * 255)
    local g = math.floor(hue_to_rgb(p, q, h) * 255)
    local b = math.floor(hue_to_rgb(p, q, h - 1/3) * 255)
    return string.format("#%02x%02x%02x", r, g, b)
end

-- This event handler will be called when the custom "close_other_tabs" event is emitted.
wezterm.on("close_other_tabs", function(window, pane)
  local mux_window = window:mux_window()
  local current_tab_id = window:active_tab():tab_id()
  local tabs_to_close = {}

  -- Collect tab objects for every tab that is not the active one.
  for _, tab in ipairs(mux_window:tabs()) do
    if tab:tab_id() ~= current_tab_id then
      table.insert(tabs_to_close, tab)
    end
  end

  -- Close each tab (iterate in reverse to avoid index shifting issues)
  for i = #tabs_to_close, 1, -1 do
    tabs_to_close[i]:activate()
    window:perform_action(wezterm.action.CloseCurrentTab { confirm = false }, pane)
  end

  -- Re-activate the original tab
  for _, tab in ipairs(mux_window:tabs()) do
    if tab:tab_id() == current_tab_id then
      tab:activate()
      break
    end
  end
end)

-- return {
--   keys = {
--     -- Change this key binding if you prefer a different shortcut.
--   },
-- })

-- Clear claude_attention when tab becomes active
wezterm.on("update-status", function(window, pane)
    local tab = window:active_tab()
    local active_pane = tab:active_pane()
    local pane_id = active_pane:pane_id()
    local user_vars = active_pane:get_user_vars()

    -- If this pane has attention and we haven't cleared it yet
    if user_vars.claude_attention and user_vars.claude_attention ~= "" and not cleared_panes[pane_id] then
        -- Mark as cleared so we don't spam
        cleared_panes[pane_id] = true
        -- Inject the escape sequence to clear the user var
        active_pane:inject_output('\027]1337;SetUserVar=claude_attention=\007')
    elseif not user_vars.claude_attention or user_vars.claude_attention == "" then
        -- Reset the cleared flag when attention is gone
        cleared_panes[pane_id] = nil
    end

    -- Show workspace name in right status with unique colour
    local workspace = window:active_workspace()
    local bg_color = hash_to_color(workspace)
    window:set_right_status(wezterm.format({
        { Foreground = { Color = "#151515" } },
        { Background = { Color = bg_color } },
        { Text = " " .. workspace .. " " },
    }))

    -- Set entire tab bar to slightly darker workspace colour
    local bar_color = hash_to_color(workspace, 0.35)
    window:set_config_overrides({
        colors = {
            tab_bar = {
                background = bar_color,
            },
        },
    })
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local pane = tab.active_pane
    local cwd = pane.current_working_dir
    local process = pane.foreground_process_name or ""

    -- Check if in headfirst directory and running node (npm run start) - PRIORITY
    local is_headfirst = cwd and cwd.file_path and cwd.file_path:find("headfirst")
    local is_node_running = process:find("node")

    -- Check if ANY tab has headfirst build script running
    local build_running_somewhere = false
    for _, t in ipairs(tabs) do
        local t_pane = t.active_pane
        local t_cwd = t_pane.current_working_dir
        local t_process = t_pane.foreground_process_name or ""
        local t_is_headfirst = t_cwd and t_cwd.file_path and t_cwd.file_path:find("headfirst")
        local t_is_node = t_process:find("node")
        if t_is_headfirst and t_is_node then
            build_running_somewhere = true
            break
        end
    end

    if is_headfirst and is_node_running then
        -- This tab is running the build script - green
        local bg = tab.is_active and "#00FF00" or "#004000"
        local fg = tab.is_active and "#151515" or "white"
        return {
            { Background = { Color = bg } },
            { Foreground = { Color = fg } },
            { Text = " HF:Build Running " },
        }
    elseif is_headfirst and not build_running_somewhere then
        -- This tab is in headfirst but no build script running anywhere - red
        local bg = tab.is_active and "#FF4444" or "#661111"
        local fg = "white"
        return {
            { Background = { Color = bg } },
            { Foreground = { Color = fg } },
            { Text = " HF:Run Build! " },
        }
    end

    -- Check if any pane in this tab has Claude attention
    local claude_attention = nil
    for _, p in ipairs(tab.panes) do
        local attention = p.user_vars.claude_attention
        if attention and attention ~= "" then
            claude_attention = attention
            break
        end
    end

    -- Check for Claude attention (only colour inactive tabs)
    if claude_attention and not tab.is_active then
        local title = tab.tab_title
        if #title == 0 then
            title = pane.title
        end
        return {
            { Background = { Color = "#FF8800" } },
            { Foreground = { Color = "#151515" } },
            { Text = " " .. title .. " " },
        }
    end

    -- Default: colour tabs based on workspace
    -- local workspace = wezterm.mux.get_active_workspace()
    -- local workspace_color = get_workspace_color(workspace) or hash_to_color(workspace)
    -- local title = tab.tab_title
    -- if #title == 0 then
    --     title = pane.title
    -- end

    -- if tab.is_active then
    --     return {
    --         { Background = { Color = workspace_color } },
    --         { Foreground = { Color = "#151515" } },
    --         { Text = " " .. title .. " " },
    --     }
    -- else
    --     return {
    --         { Background = { Color = "#151515" } },
    --         { Foreground = { Color = workspace_color } },
    --         { Text = " " .. title .. " " },
    --     }
    -- end
end)

return {
    -- default_prog = {'/Users/cemalokten/.cargo/bin/nu'},
    color_scheme = "Jellybeans (Gogh)",
    -- font = wezterm.font('JetBrains Mono', { weight = 'Light' }),
    -- font = wezterm.font { family = 'Pragmata Pro Mono' },
    -- font = wezterm.font ( 'Pragmasevka', { weight = 'Medium', }),
    font = wezterm.font("Iosevka Term SS08", { weight = 'Regular' }),
    -- font = wezterm.font("Iosevka Term", {weight = "Regular"}),
    -- font = wezterm.font("Iosevka Term"),
    -- font = wezterm.font ( 'TX-02', { weight = 'Light', }),
    -- font = wezterm.font { family = 'Essential PragmataPro' },
    -- font = wezterm.font('Berkeley Mono'),
    -- font = wezterm.font('Berkeley Mono'),
    command_palette_font_size = 25,
    command_palette_font = wezterm.font("Iosevka Term SS08", {weight = "Medium"}),
    command_palette_bg_color = "#151515",
    command_palette_fg_color = "#8787D7",
    command_palette_rows = 10,
    -- CharSelect / InputSelector styling (resurrect fuzzy loader)
    char_select_fg_color = "#8787D7",
    char_select_bg_color = "#151515",
    freetype_load_target = "Normal",
    freetype_load_flags = "NO_HINTING",
    force_reverse_video_cursor = true,
    term = "xterm-256color",
    use_ime = false,
    scrollback_lines = 10000,
    -- line_height = 1.25,
    -- cell_width = 1.0,
    -- line_height = 1.35,
    -- font_size = 12, -- Standard
    -- font_size = 14, -- Standard
    -- font_size = 16, -- Standard
    -- font_size = 18, -- Standard
    -- font_size = 19, -- Standard
    -- harfbuzz_features = {"calt=0", "clig=0", "liga=0"},
    font_size = 14, -- Laptop small
    font_size = 15, -- Laptop
    font_size = 16, -- 27" Screen Small
    font_size = 17, -- 27" Screen Medium
    font_size = 18, -- 27" Screen Large
    font_size = 20, -- 27" Screen Large
    font_size = 22, -- 27" Screen Large
    tab_max_width = 500,
    tab_bar_at_bottom = false,
    line_height = 1.0,
    use_fancy_tab_bar = false,
    cursor_blink_rate = 0,
    send_composed_key_when_left_alt_is_pressed = false,
    -- Performace settings
    front_end = "WebGpu",
    max_fps = 240,
    colors = {
        copy_mode_active_highlight_fg = {Color = "#ffffff"},
        copy_mode_active_highlight_bg = {Color = "#8787D7"},
        copy_mode_inactive_highlight_fg = {Color = "White"},
        copy_mode_inactive_highlight_bg = {Color = "Blue"},
        quick_select_label_fg = {Color = "white"},
        quick_select_label_bg = {Color = "Yellow"},
        quick_select_match_fg = {Color = "grey"},
        quick_select_match_bg = {Color = "Yellow"},
        background = "#151515",
        tab_bar = {
            -- The color of the strip that goes along the top of the window
            -- (does not apply when fancy tab bar is in use)
            background = "#151515",
            active_tab = {
                -- The color of the background area for the tab
                bg_color = "#8787D7",
                -- The color of the text for the tab
                fg_color = "black",
                -- Specify whether you want "Half", "Normal" or "Bold" intensity for the
                -- label shown for this tab.
                -- The default is "Normal"
                intensity = "Normal",
                -- Specify whether you want "None", "Single" or "Double" underline for
                -- label shown for this tab.
                -- The default is "None"
                underline = "None",
                -- Specify whether you want the text to be italic (true) or not (false)
                -- for this tab.  The default is false.
                italic = false,
                -- Specify whether you want the text to be rendered with strikethrough (true)
                -- or not for this tab.  The default is false.
                strikethrough = false
            },
            -- Inactive tabs are the tabs that do not have focus
            inactive_tab = {
                fg_color = "#8787D7",
                -- The color of the text for the tab
                bg_color = "#151515"

                -- The same options that were listed under the `active_tab` section above
                -- can also be used for `inactive_tab`.
            }
        }
    },
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    },
    window_decorations = "RESIZE",
    window_background_opacity = 1,
    pane_focus_follows_mouse = false,
    inactive_pane_hsb = {
        brightness = 0.1
    },
    keys = {
        -- Disable default tab switching to allow Helix to use these keys
        {
            key = "[",
            mods = "CTRL",
            action = wezterm.action.DisableDefaultAssignment
        },
        {
            key = "]",
            mods = "CTRL",
            action = wezterm.action.DisableDefaultAssignment
        },
        -- This will create a new split and run your default program inside it
        {key = " ", mods = "SHIFT", action = wezterm.action.SendString("_")},
        {
            key = "0",
            mods = "CTRL",
            action = wezterm.action.PaneSelect {
                mode = "SwapWithActive",
                alphabet = "1234567890"
            }
        },
        {
            key = "e",
            mods = "CTRL|SHIFT|ALT|CMD",
            action = wezterm.action.SplitVertical {domain = "CurrentPaneDomain"}
        },
        {
            key = "w",
            mods = "CTRL|SHIFT|ALT|CMD",
            action = wezterm.action.SplitHorizontal {domain = "CurrentPaneDomain"}
        },
        {
            key = "w",
            mods = "CMD",
            action = wezterm.action.CloseCurrentPane {confirm = true}
        },
        {   key = "w",
            mods = "CMD|SHIFT|CTRL",
            action = wezterm.action{EmitEvent = "close_other_tabs"}
        },
        {
            key = "m",
            mods = "CTRL|SHIFT|ALT|CMD",
            action = wezterm.action.ActivatePaneDirection("Next")
        },
        {
            key = "3",
            mods = "OPT",
            action = wezterm.action.SendString("#")
        },
        {
            key = "p",
            mods = "CTRL|SHIFT|ALT|CMD",
            action = wezterm.action.ActivateCommandPalette
        },
        {
            key = "t",
            mods = "CTRL|SHIFT|ALT|CMD",
            action = wezterm.action.ShowLauncherArgs {
                flags = "FUZZY|TABS"
            }
        },
        {
            key = "Enter",
            mods = "SHIFT",
            action = wezterm.action {
                SendString = "\x1b\r"
            }
        },
        {
            key = "]",
            mods = "CTRL|SHIFT|ALT|CMD",
            action = wezterm.action.SwitchWorkspaceRelative(1)
        },
        {
            key = "[",
            mods = "CTRL|SHIFT|ALT|CMD",
            action = wezterm.action.SwitchWorkspaceRelative(-1)
        },
        {
            key = "g",
            mods = "CTRL|SHIFT|ALT|CMD",
            action = wezterm.action.PromptInputLine {
                description = "Enter new workspace name",
                action = wezterm.action_callback(function(window, pane, line)
                    if line then
                        wezterm.mux.rename_workspace(window:active_workspace(), line)
                    end
                end)
            }
        },
        -- Resurrect: Save workspace state
        {
            key = "s",
            mods = "CTRL|SHIFT|ALT|CMD",
            action = wezterm.action_callback(function(win, pane)
                resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
            end),
        },
        -- Resurrect: Load state via fuzzy finder
        {
            key = "f",
            mods = "CTRL|SHIFT|ALT|CMD",
            action = wezterm.action_callback(function(win, pane)
                resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
                    local type = string.match(id, "^([^/]+)") -- match before '/'
                    id = string.match(id, "([^/]+)$") -- match after '/'
                    id = string.match(id, "(.+)%..+$") -- remove file extension
                    if type == "workspace" then
                        local state = resurrect.state_manager.load_state(id, "workspace")
                        local workspace_opts = {
                            relative = true,
                            restore_text = true,
                            on_pane_restore = resurrect.tab_state.default_on_pane_restore,
                            spawn_in_workspace = true,
                        }
                        resurrect.workspace_state.restore_workspace(state, workspace_opts)
                        wezterm.mux.set_active_workspace(id)
                    elseif type == "window" then
                        local state = resurrect.state_manager.load_state(id, "window")
                        local window_opts = {
                            relative = true,
                            restore_text = true,
                            on_pane_restore = resurrect.tab_state.default_on_pane_restore,
                            window = pane:window(),
                        }
                        resurrect.window_state.restore_window(pane:window(), state, window_opts)
                    elseif type == "tab" then
                        local state = resurrect.state_manager.load_state(id, "tab")
                        local tab_opts = {
                            relative = true,
                            restore_text = true,
                            on_pane_restore = resurrect.tab_state.default_on_pane_restore,
                        }
                        resurrect.tab_state.restore_tab(pane:tab(), state, tab_opts)
                    end
                end, {
                    fmt_workspace = function(label)
                        local name = string.match(label, "(.+)%.json$") or label
                        return wezterm.format({
                            "ResetAttributes",
                            { Background = { Color = "#151515" } },
                            { Foreground = { Color = hash_to_color(name) } },
                            { Text = " " .. name},
                        })
                    end,
                    fmt_window = function(label)
                        local name = string.match(label, "(.+)%.json$") or label
                        return wezterm.format({
                            "ResetAttributes",
                            { Foreground = { Color = "#151515" } },
                            { Background = { Color = hash_to_color(name) } },
                            { Text = " " .. name},
                        })
                    end,
                    fmt_tab = function(label)
                        local name = string.match(label, "(.+)%.json$") or label
                        return wezterm.format({
                            "ResetAttributes",
                            { Foreground = { Color = "#151515" } },
                            { Background = { Color = hash_to_color(name) } },
                            { Text = " " .. name},
                        })
                    end,
                })
            end),
       },
        -- Resurrect: Delete saved state
        {
            key = "d",
            mods = "CTRL|SHIFT|ALT|CMD",
            action = wezterm.action_callback(function(win, pane)
                resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
                    resurrect.state_manager.delete_state(id)
                end, {
                    title = "Delete State",
                    description = "Select State to Delete and press Enter = accept, Esc = cancel, / = filter",
                    fuzzy_description = "Search State to Delete: ",
                    is_fuzzy = true,
                    fmt_workspace = function(label)
                        local name = string.match(label, "(.+)%.json$") or label
                        return wezterm.format({
                            "ResetAttributes",
                            { Background = { Color = "#151515" } },
                            { Foreground = { Color = hash_to_color(name) } },
                            { Text = " " .. name},
                        })
                    end,
                    fmt_window = function(label)
                        local name = string.match(label, "(.+)%.json$") or label
                        return wezterm.format({
                            "ResetAttributes",
                            { Foreground = { Color = "#151515" } },
                            { Background = { Color = hash_to_color(name) } },
                            { Text = " " .. name},
                        })
                    end,
                    fmt_tab = function(label)
                        local name = string.match(label, "(.+)%.json$") or label
                        return wezterm.format({
                            "ResetAttributes",
                            { Foreground = { Color = "#151515" } },
                            { Background = { Color = hash_to_color(name) } },
                            { Text = " " .. name},
                        })
                    end,
                })
            end),
        },
    }
}
