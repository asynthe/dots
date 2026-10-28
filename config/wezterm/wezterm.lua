local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Win+<key> is mostly reserved by Windows (Win+L locks, Win+Z snaps, ...), so use Ctrl there.
local is_windows = wezterm.target_triple:find("windows") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil
local mod = is_windows and "CTRL" or "SUPER"

local keybinds = {
    { key = "i", mods = mod, action = act.ShowDebugOverlay },
    { key = "-", mods = mod, action = act.DecreaseFontSize },
    { key = "=", mods = mod, action = act.IncreaseFontSize },

    -- Move pane to a new tab
    {
        key = "n",
        mods = mod .. "|SHIFT",
        action = wezterm.action_callback(function(win, pane)
            local tab, window = pane:move_to_new_tab()
        end),
    },

    { key = "c", mods = mod .. "|SHIFT", action = act.CopyTo("Clipboard") },
    { key = "v", mods = mod .. "|SHIFT", action = act.PasteFrom("PrimarySelection") },

    { key = "Tab", mods = mod, action = act.ActivateTabRelative(1) }, -- Change to right tab
    { key = "Tab", mods = mod .. "|SHIFT", action = act.ActivateTabRelative(-1) }, -- Change to left tab
    { key = "]", mods = mod, action = act.MoveTabRelative(1) },
    { key = "[", mods = mod, action = act.MoveTabRelative(-1) },

    { key = "\\", mods = mod, action = act.SplitHorizontal },
    { key = "|", mods = mod .. "|SHIFT", action = act.SplitVertical },
    { key = "w", mods = mod, action = act.CloseCurrentPane({ confirm = false }) }, -- This also closes the window if only one pane left.
    { key = "t", mods = mod, action = act.SpawnTab("CurrentPaneDomain") },
    { key = "z", mods = is_windows and "CTRL|SHIFT" or "SUPER", action = act.TogglePaneZoomState }, -- Fullscreen the current pane (plain Ctrl+z is undo/suspend)

    { key = "h", mods = mod .. "|ALT", action = act.RotatePanes("CounterClockwise") },
    { key = "l", mods = mod .. "|ALT", action = act.RotatePanes("Clockwise") },

    { key = "h", mods = mod, action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = mod, action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = mod, action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = mod, action = act.ActivatePaneDirection("Right") },

    { key = "h", mods = mod .. "|SHIFT", action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "j", mods = mod .. "|SHIFT", action = act.AdjustPaneSize({ "Down", 1 }) },
    { key = "k", mods = mod .. "|SHIFT", action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "l", mods = mod .. "|SHIFT", action = act.AdjustPaneSize({ "Right", 1 }) },

    -- for i = 1, 8 do
    -- CTRL+ALT + number to activate that tab
}

local opts = {
    font = wezterm.font_with_fallback({
        { family = "TX-02", stretch = "Condensed" },
        "JetBrainsMono Nerd Font",
        "Noto Color Emoji",
    }),
    font_size = 12.0,

    window_background_opacity = 0.7,
    text_background_opacity = 1,

    disable_default_key_bindings = true,
    keys = keybinds,

    tab_bar_at_bottom = true,
    use_fancy_tab_bar = false,
    show_new_tab_button_in_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,

    cursor_blink_rate = 1000,
    default_cursor_style = "BlinkingUnderline",

    debug_key_events = true,
    alternate_buffer_wheel_scroll_speed = 1,
    window_close_confirmation = "NeverPrompt",
    audible_bell = "Disabled",
}

if is_windows then
    local pwsh = io.open("C:/Program Files/PowerShell/7/pwsh.exe", "r")
    if pwsh then
        pwsh:close()
    end
    opts.default_prog = { pwsh and "pwsh.exe" or "powershell.exe", "-NoLogo" }
    opts.window_background_opacity = 0.85
end

-- TX-02 is in assets/fonts, installed by hand on non-NixOS systems.
if is_linux then
end

return opts
