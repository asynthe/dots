local wezterm = require "wezterm"
local act = wezterm.action
local config = wezterm.config_builder()

-- Win+<key> is mostly reserved by Windows (Win+L locks, Win+Z snaps, ...), so use Ctrl there.
local is_windows = wezterm.target_triple:find("windows") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil
local mod = is_windows and "CTRL" or "SUPER"

local keybinds = {
  -- Main
  --{ key = 'v', mods = 'SUPER', action = act.SplitHorizontal { args =  { 'alsamixer' }, }, }, -- Open alsamixer
  -- { key = 'w', mods = 'CTRL', action = act.CloseCurrentTab { confirm = true }, },
  { key = 'i', mods = mod, action = act.ShowDebugOverlay },
  { key = '-', mods = mod, action = act.DecreaseFontSize },
  { key = '=', mods = mod, action = act.IncreaseFontSize },

  -- Move pane to a new tab
  { key = 'n', mods = mod .. '|SHIFT', 
      action = wezterm.action_callback(function(win, pane)
      local tab, window = pane:move_to_new_tab()
    end),
  },

  -- Clipboard
  { key = 'c', mods = mod .. '|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = mod .. '|SHIFT', action = act.PasteFrom 'PrimarySelection' },

  -- Tabs
  { key = 'Tab', mods = mod, action = act.ActivateTabRelative(1) }, -- Change to right tab
  { key = 'Tab', mods = mod .. '|SHIFT', action = act.ActivateTabRelative(-1) }, -- Change to left tab
  { key = ']', mods = mod, action = act.MoveTabRelative(1) }, -- Move tab right
  { key = '[', mods = mod, action = act.MoveTabRelative(-1) }, -- Move tab left

  -- Pane
  { key = '\\', mods = mod, action = act.SplitHorizontal },
  { key = '|', mods = mod .. '|SHIFT', action = act.SplitVertical },
  { key = 'w', mods = mod, action = act.CloseCurrentPane { confirm = false } }, -- This also closes the window if only one pane left.
  { key = 't', mods = mod, action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'z', mods = is_windows and 'CTRL|SHIFT' or 'SUPER', action = act.TogglePaneZoomState }, -- Fullscreen the current pane (plain Ctrl+z is undo/suspend)

  -- Pane Switching
  { key = 'h', mods = mod .. '|ALT', action = act.RotatePanes 'CounterClockwise' },
  { key = 'l', mods = mod .. '|ALT', action = act.RotatePanes 'Clockwise' },

  -- Pane focus
  { key = 'h', mods = mod, action = act.ActivatePaneDirection("Left") },
  { key = 'j', mods = mod, action = act.ActivatePaneDirection("Down") },
  { key = 'k', mods = mod, action = act.ActivatePaneDirection("Up") },
  { key = 'l', mods = mod, action = act.ActivatePaneDirection("Right") },

  -- Pane resizing
  { key = 'h', mods = mod .. '|SHIFT', action = act.AdjustPaneSize { 'Left', 1 } },
  { key = 'j', mods = mod .. '|SHIFT', action = act.AdjustPaneSize { 'Down', 1 } },
  { key = 'k', mods = mod .. '|SHIFT', action = act.AdjustPaneSize { 'Up', 1 } },
  { key = 'l', mods = mod .. '|SHIFT', action = act.AdjustPaneSize { 'Right', 1 } },

  -- Workspaces with CTRL
  -- { key = '1', mods = 'CTRL', action = act.ActivateTab=0 },
  -- { key = '2', mods = 'CTRL', action = act.ActivateTab=1 },
  -- { key = '3', mods = 'CTRL', action = act.ActivateTab=2 },
  -- { key = '4', mods = 'CTRL', action = act.ActivateTab=3 },
  -- { key = '5', mods = 'CTRL', action = act.ActivateTab=4 },
  -- { key = '6', mods = 'CTRL', action = act.ActivateTab=5 },
  -- { key = '7', mods = 'CTRL', action = act.ActivateTab=6 },
  -- { key = '8', mods = 'CTRL', action = act.ActivateTab=7 },
  -- { key = '9', mods = 'CTRL', action = act.ActivateTab=-1 },

  -- for i = 1, 8 do
  -- CTRL+ALT + number to activate that tab
  -- table.insert(config.keys, {
  --   key = tostring(i),
  --   mods = 'CTRL|ALT',
 --    action = act.ActivateTab(i - 1),
 --  })
}

local opts = {
    -- General
    font = wezterm.font_with_fallback({
        { family = "TX-02", stretch = "Condensed" },
        "JetBrainsMono Nerd Font",
        "Noto Color Emoji",
    }),
    font_size = 11.0,
    --use_ime = true,
    --treat_east_asian_ambiguous_width_as_wide = true,

    -- Transparency
    window_background_opacity = 0.7,
    text_background_opacity = 1,

    -- Keys
    disable_default_key_bindings = true,
    keys = keybinds,

    -- Tab Bar
    tab_bar_at_bottom = true,
    use_fancy_tab_bar = false,
    show_new_tab_button_in_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,

    -- Cursor
    cursor_blink_rate = 1000,
    --default_cursor_style = 'BlinkingBlock',
    default_cursor_style = 'BlinkingUnderline',
    --hide_mouse_cursor_when_typing = true,
  
    -- Other
    debug_key_events = true,
    alternate_buffer_wheel_scroll_speed = 1,
    window_close_confirmation = "NeverPrompt",
    audible_bell = 'Disabled',
    --freetype_load_target = "Normal",
    --freetype_load_flags = 'NO_AUTOHINT',

    -- Window Padding
    --window_padding = 
    --    left = 2,
    --right = 0,
    --top = 2,
    --bottom = 0,
    --}
}

-- --------------- Per platform ---------------
-- Everything above is shared; these blocks only override/add to `opts`.

-- Windows
-- TX-02 isn't packaged; windows/link.ps1 installs it per-user from assets/fonts.
if is_windows then
    -- Default is cmd.exe; prefer pwsh (7) when installed.
    local pwsh = io.open("C:/Program Files/PowerShell/7/pwsh.exe", "r")
    if pwsh then pwsh:close() end
    opts.default_prog = { pwsh and "pwsh.exe" or "powershell.exe", "-NoLogo" }
    opts.window_background_opacity = 0.85
    --opts.win32_system_backdrop = "Acrylic" -- Auto, Disabled, Acrylic, Mica, Tabbed (Acrylic blurs what's behind)

    -- Start in NixOS
    --opts.default_domain = "WSL:NixOS" -- Doesn't take the `cd ~`
    --opts.default_prog = { "wsl.exe", "~" }
    --opts.wsl_domains = {
    --    {
    --        name = "WSL:NixOS",
    --        distribution = "NixOS",
    --        default_cwd = "~",
    --    },
    --}
end

-- Linux
-- TX-02 comes from ~/.local/share/fonts (gentoo/setup.md) or look.nix.
if is_linux then
    -- opts.font_size = 12.0
end

return opts
