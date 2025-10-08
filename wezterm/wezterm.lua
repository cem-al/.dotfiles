local wezterm = require "wezterm"
return {
    -- default_prog = {'/Users/cemalokten/.cargo/bin/nu'},
    color_scheme = "Jellybeans (Gogh)",
    -- font = wezterm.font('JetBrains Mono', { weight = 'Regular' }),
    -- font = wezterm.font { family = 'Pragmata Pro Mono' },
    -- font = wezterm.font ( 'Pragmasevka', { weight = 'Medium', }),
    font = wezterm.font("Iosevka Term SS08"),
    -- font = wezterm.font("Iosevka Term", {weight = "Regular"}),
    -- font = wezterm.font("Iosevka Term"),
    -- font = wezterm.font ( 'TX-02', { weight = 'Light', }),
    -- font = wezterm.font { family = 'Essential PragmataPro' },
    -- font = wezterm.font('Berkeley Mono'),
    -- font = wezterm.font('Berkeley Mono'),
    command_palette_font_size = 25,
    command_palette_font = wezterm.font("Iosevka Term SS08", {weight = "Medium"}),
    command_palette_bg_color = "#151515", -- Background colour for command palette
    command_palette_fg_color = "#8787D7", -- Background colour for command palette
    command_palette_rows = 10,
    freetype_load_target = "Normal",
    freetype_load_flags = "NO_HINTING",
    force_reverse_video_cursor = true,
    term = "xterm-256color",
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
    tab_max_width = 500,
    line_height = 1.0,
    use_fancy_tab_bar = false,
    cursor_blink_rate = 0,
    send_composed_key_when_left_alt_is_pressed = false,
    -- Performace settings
    front_end = "WebGpu",
    max_fps = 144,
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
        brightness = 0.5
    },
    keys = {
        -- This will create a new split and run your default program inside it
        {
            key = "w",
            mods = "SHIFT|CMD",
            action = wezterm.action.SplitHorizontal {domain = "CurrentPaneDomain"}
        },
        {
            key = "e",
            mods = "SHIFT|CMD",
            action = wezterm.action.SplitVertical {domain = "CurrentPaneDomain"}
        },
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
            key = "w",
            mods = "CMD",
            action = wezterm.action.CloseCurrentPane {confirm = true}
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
        }
    }
}
