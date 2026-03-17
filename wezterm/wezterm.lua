local wezterm = require "wezterm"
-- Load the theme rotator plugin
-- local theme_rotator = wezterm.plugin.require 'https://github.com/koh-sh/wezterm-theme-rotator'

-- Favourite themes:
-- Hybrid 465
-- Homebrew light
-- GruvboxDarkHard
-- Gruvbox dark, soft (base16)
-- Gruvbox dark, pale (base16)
-- Gruvbox Material (Gogh)
-- Paper 699
-- rose pine dawn 775
-- sleepyhollow 823
-- Belafonte Day
-- Kanagawa Dragon (Gogh)
-- Novel

local config = {
    -- color_scheme = "Jellybeans (Gogh)",
    -- color_scheme = "Cemal Dark",
    color_scheme = "Hybrid",
    -- color_scheme = "Homebrew Light",
    -- color_scheme = "GruvboxDarkHard",
    -- color_scheme = "Gruvbox dark soft (base16)",
    -- color_scheme = "Gruvbox dark pale (base16)",
    -- color_scheme = "Gruvbox Material (Gogh)",
    -- color_scheme = "Paper 699",
    -- color_scheme = "rose pine dawn 775",
    color_scheme = "SleepyHollow",
    -- color_scheme = "Belafonte Day",
    -- color_scheme = "Kanagawa Dragon (Gogh)",
    -- color_scheme = "Novel",
    -- color_scheme = "s3r0 modified (terminal.sexy)",
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
        brightness = 0.6,
    },
    command_palette_font_size = 25,
    command_palette_font = wezterm.font("Iosevka Term SS08", { weight = "Medium" }),
    -- command_palette_bg_color = "#151515",
    -- command_palette_fg_color = "#8787D7",
    command_palette_rows = 10,
    -- char_select_fg_color = "#8787D7",
    -- char_select_bg_color = "#151515",
    -- colors = {
    --     background = "#151515",
    --     copy_mode_active_highlight_fg = { Color = "#ffffff" },
    --     copy_mode_active_highlight_bg = { Color = "#8787D7" },
    --     copy_mode_inactive_highlight_fg = { Color = "White" },
    --     copy_mode_inactive_highlight_bg = { Color = "Blue" },
    --     quick_select_label_fg = { Color = "white" },
    --     quick_select_label_bg = { Color = "Yellow" },
    --     quick_select_match_fg = { Color = "grey" },
    --     quick_select_match_bg = { Color = "Yellow" },
    --     tab_bar = {
    --         background = "#151515",
    --         active_tab = {
    --             bg_color = "#8787D7",
    --             fg_color = "black",
    --         },
    --         inactive_tab = {
    --             fg_color = "#8787D7",
    --             bg_color = "#151515",
    --         },
    --     },
    -- },
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

-- Apply the theme rotator plugin
-- theme_rotator.apply_to_config(config, {
--     next_theme_key = 'v',
--     next_theme_mods = 'CTRL|SHIFT|ALT|CMD',
--     prev_theme_key = 'c',
--     prev_theme_mods = 'CTRL|SHIFT|ALT|CMD',
--     random_theme_key = 'r',
--     random_theme_mods = 'CTRL|SHIFT|ALT|CMD',
-- })

return config
