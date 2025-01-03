local wezterm = require "wezterm"
local act = wezterm.action

local keybinds = {
  -- Main
  --{ key = 'v', mods = 'SUPER', action = act.SplitHorizontal { args =  { 'alsamixer' }, }, }, -- Open alsamixer
  { key = 'i', mods = 'CTRL', action = act.ShowDebugOverlay },
  { key = 'z', mods = 'CTRL|SHIFT', action = act.TogglePaneZoomState },
  -- { key = 'w', mods = 'CTRL', action = act.CloseCurrentTab { confirm = true }, },

  -- Clipboard -- FIX PLZ
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'PrimarySelection' },

  -- Tabs
  { key = '[', mods = 'CTRL', action = act.MoveTabRelative(-1) }, -- Move tab left
  { key = ']', mods = 'CTRL', action = act.MoveTabRelative(1) }, -- Move tab right
  { key = 't', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },

  -- Pane
  { key = '\\', mods = 'CTRL', action = act.SplitHorizontal },
  { key = '|', mods = 'CTRL|SHIFT', action = act.SplitVertical },
  { key = 'w', mods = 'CTRL', action = act.CloseCurrentPane { confirm = false } }, -- This also closes the window if only one pane left.

  -- Pane Switching
  { key = 'h', mods = 'SUPER|SHIFT', action = act.RotatePanes 'CounterClockwise' },
  { key = 'l', mods = 'SUPER|SHIFT', action = act.RotatePanes 'Clockwise' },

  -- Pane focus w/ SUPER
  { key = 'h', mods = 'SUPER', action = act.ActivatePaneDirection("Left") },
  { key = 'j', mods = 'SUPER', action = act.ActivatePaneDirection("Down") },
  { key = 'k', mods = 'SUPER', action = act.ActivatePaneDirection("Up") },
  { key = 'l', mods = 'SUPER', action = act.ActivatePaneDirection("Right") },

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
  -- Keys
  -- disable_default_key_bindings = true,
  keys = keybinds,

  -- Tab Bar
  show_new_tab_button_in_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,
  -- hide_mouse_cursor_when_typing = true,

  -- Cursor
  -- cursor_blink_rate = 800,
  -- default_cursor_style = 'BlinklingBlock',
  -- default_cursor_style = 'BlinkingUnderline',

  -- Other
  debug_key_events = true,
  alternate_buffer_wheel_scroll_speed = 1,
  window_close_confirmation = "NeverPrompt",
  audible_bell = 'Disabled',
  -- freetype_load_target = "Normal",
  -- freetype_load_flags = 'NO_AUTOHINT',

  -- Window Padding
  -- window_padding = {
  --  left = 0,
  --  right = 0,
  --  top = 0,
  --  bottom = 0,
  -- },
}
