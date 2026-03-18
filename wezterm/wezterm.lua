local wezterm = require "wezterm"
local scheme = wezterm.color.get_builtin_schemes()["SleepyHollow"]

-- Track which tabs have had a bell fire (for flashing)
local bell_tabs = {}

wezterm.on('bell', function(window, pane)
    local tab_id = pane:tab():tab_id()
    bell_tabs[tab_id] = true
    -- Flash for 2 seconds then clear
    wezterm.time.call_after(2, function()
        bell_tabs[tab_id] = nil
        window:invalidate()
    end)
    window:invalidate()
    window:toast_notification('Claude Code', 'Task complete', nil, 4000)
end)

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local title = tab.active_pane.title
    local tab_id = tab.tab_id
    if bell_tabs[tab_id] then
        return {
            { Background = { Color = '#e6a003' } },
            { Foreground = { Color = '#1a1a1a' } },
            { Text = ' ⚡ ' .. title .. ' ' },
        }
    end
end)

local config = {
    -- color_scheme = "Jellybeans (Gogh)",
    -- color_scheme = "Cemal Dark",
    color_scheme = "SleepyHollow",
    -- color_scheme = "GruvboxDarkHard",
    -- color_scheme = "Gruvbox dark soft (base16)",
    -- color_scheme = "Gruvbox dark pale (base16)",
    -- color_scheme = "Gruvbox Material (Gogh)",
    -- color_scheme = "Rosé Pine Dawn (Gogh)",
    -- color_scheme = "Novel",
    font = wezterm.font("Iosevka Term SS08", { weight = "Regular" }),
    font_size = 18,
    line_height = 1.0,
    freetype_load_target = "Normal",
    freetype_load_flags = "NO_HINTING",
    force_reverse_video_cursor = true,
    term = "xterm-256color",
    use_ime = false,
    scrollback_lines = 10000,
    tab_max_width = 500,
    tab_bar_at_bottom = false,
    use_fancy_tab_bar = false,
    cursor_blink_rate = 0,
    send_composed_key_when_left_alt_is_pressed = false,
    front_end = "WebGpu",
    max_fps = 240,
    window_decorations = "RESIZE",
    window_background_opacity = 1,
    pane_focus_follows_mouse = false,
    inactive_pane_hsb = {
        brightness = 0.8,
    },
    command_palette_font_size = 25,
    command_palette_font = wezterm.font("Iosevka Term SS08", { weight = "Medium" }),
    command_palette_rows = 10,
    colors = {
        tab_bar = {
            active_tab = {
                bg_color = scheme.brights[4],
                fg_color = scheme.background,
            },
            inactive_tab = {
                bg_color = scheme.background,
                fg_color = scheme.foreground,
            },
        },
    },
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    keys = {
        { key = " ", mods = "SHIFT", action = wezterm.action.SendString("_") },
        { key = "0", mods = "CTRL", action = wezterm.action.PaneSelect { mode = "SwapWithActive", alphabet = "1234567890" } },
        { key = "3", mods = "OPT", action = wezterm.action.SendString("#") },
        { key = "[", mods = "CTRL|SHIFT|ALT|CMD", action = wezterm.action.SwitchWorkspaceRelative(-1) },
        { key = "]", mods = "CTRL|SHIFT|ALT|CMD", action = wezterm.action.SwitchWorkspaceRelative(1) },
        { key = "e", mods = "CTRL|SHIFT|ALT|CMD", action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" } },
        { key = "Enter", mods = "SHIFT", action = wezterm.action { SendString = "\x1b\r" } },
        {
            key = "g",
            mods = "CTRL|SHIFT|ALT|CMD",
            action = wezterm.action.PromptInputLine {
                description = "Enter new workspace name",
                action = wezterm.action_callback(function(window, pane, line)
                    if line then
                        wezterm.mux.rename_workspace(window:active_workspace(), line)
                    end
                end),
            },
        },
        { key = "m", mods = "CTRL|SHIFT|ALT|CMD", action = wezterm.action.ActivatePaneDirection("Next") },
        { key = "p", mods = "CTRL|SHIFT|ALT|CMD", action = wezterm.action.ActivateCommandPalette },
        { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane { confirm = true } },
        { key = "w", mods = "CTRL|SHIFT|ALT|CMD", action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
    },
}

return config
