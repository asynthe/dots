-- Asynthe's Wezterm config
-- 2025

local wezterm = require "wezterm"
local act = wezterm.action
local config = wezterm.config_builder()

-- NixOS
-- config.default_domain = 'WSL:NixOS'

local keybinds = {
  -- Main
  --{ key = 'v', mods = 'SUPER', action = act.SplitHorizontal { args =  { 'alsamixer' }, }, }, -- Open alsamixer
  { key = 'i', mods = 'CTRL', action = act.ShowDebugOverlay },
  { key = 'z', mods = 'CTRL|SHIFT', action = act.TogglePaneZoomState },
  -- { key = 'w', mods = 'CTRL', action = act.CloseCurrentTab { confirm = true }, },

  -- Move pane to a new tab
  { key = 'n', mods = 'CTRL|SHIFT', 
      action = wezterm.action_callback(function(win, pane)
      local tab, window = pane:move_to_new_tab()
    end),
  },

  -- Clipboard -- FIX PLZ
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'PrimarySelection' },

  -- Tabs
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) }, -- Change to right tab
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) }, -- Change to left tab
  { key = ']', mods = 'CTRL', action = act.MoveTabRelative(1) }, -- Move tab right
  { key = '[', mods = 'CTRL', action = act.MoveTabRelative(-1) }, -- Move tab left

  -- Pane
  { key = 't', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = '\\', mods = 'CTRL', action = act.SplitHorizontal },
  { key = '|', mods = 'CTRL|SHIFT', action = act.SplitVertical },
  { key = 'w', mods = 'CTRL', action = act.CloseCurrentPane { confirm = false } }, -- This also closes the window if only one pane left.

  -- Pane Switching
  { key = 'h', mods = 'SUPER|SHIFT', action = act.RotatePanes 'CounterClockwise' },
  { key = 'l', mods = 'SUPER|SHIFT', action = act.RotatePanes 'Clockwise' },

  -- Pane focus w/ SUPER
  { key = 'h', mods = 'CTRL', action = act.ActivatePaneDirection("Left") },
  { key = 'j', mods = 'CTRL', action = act.ActivatePaneDirection("Down") },
  { key = 'k', mods = 'CTRL', action = act.ActivatePaneDirection("Up") },
  { key = 'l', mods = 'CTRL', action = act.ActivatePaneDirection("Right") },

  -- { key = 'h', mods = 'SUPER', action = act.ActivatePaneDirection("Left") },
  -- { key = 'j', mods = 'SUPER', action = act.ActivatePaneDirection("Down") },
  -- { key = 'k', mods = 'SUPER', action = act.ActivatePaneDirection("Up") },
  -- { key = 'l', mods = 'SUPER', action = act.ActivatePaneDirection("Right") },

  -- Pane resizing
  { key = 'h', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Left', 1 } },
  { key = 'j', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Down', 1 } },
  { key = 'k', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Up', 1 } },
  { key = 'l', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Right', 1 } },

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

return {

    -- Start in NixOS and in ~
    default_prog = { "wsl.exe", "-d", "NixOS", "--cd", "~" },
    enable_wayland = true,
    set_environment_variables = {
        WEZTERM_WSL_ENABLE_WAYLAND = "1",
        WAYLAND_DISPLAY = os.getenv("WAYLAND_DISPLAY") or "wayland-0",
        XDG_RUNTIME_DIR = os.getenv("XDG_RUNTIME_DIR") or "/run/user/$(id -u)"
    },

    -- Transparency
    --window_background_opacity = 0.8,
    --text_background_opacity = 0.989,
    window_background_opacity = 0,
    win32_system_backdrop = "Mica", -- Auto, Disabled, Acrylic, Mica, Tabbed

    -- Keys
    disable_default_key_bindings = true,
    keys = keybinds,

    -- Tab Bar
    show_new_tab_button_in_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,
    -- hide_mouse_cursor_when_typing = true,

    -- Cursor
    cursor_blink_rate = 1000,
    --default_cursor_style = 'BlinkingBlock',
    default_cursor_style = 'BlinkingUnderline',
  
    -- Other
    debug_key_events = true,
    alternate_buffer_wheel_scroll_speed = 1,
    window_close_confirmation = "NeverPrompt",
    audible_bell = 'Disabled',
    -- freetype_load_target = "Normal",
    -- freetype_load_flags = 'NO_AUTOHINT',

    -- Window Padding
    --window_padding = {
    --  left = 0,
    --  right = 0,
    --  top = 0,
    --  bottom = 0,
    --},
}
