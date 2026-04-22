local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Theme
local scheme = 'Apple System Colors'
config.color_scheme = scheme

-- Fonts
config.font_size = 11

-- Hotkeys
config.keys = {
    {key="1", mods="ALT", action=wezterm.action{ActivateTab=0}},
    {key="2", mods="ALT", action=wezterm.action{ActivateTab=1}},
    {key="3", mods="ALT", action=wezterm.action{ActivateTab=2}},
    {key="4", mods="ALT", action=wezterm.action{ActivateTab=3}},
    {key="5", mods="ALT", action=wezterm.action{ActivateTab=4}},
}

-- Tabs font
config.window_frame = {
  font = wezterm.font { family = 'Roboto', weight = 'Regular' },
  border_left_width = '1px',
  border_right_width = '1px',
  border_bottom_height = '1px',
  border_top_height = '1px',
  border_left_color = '#555555',
  border_right_color = '#555555',
  border_bottom_color = '#555555',
  border_top_color = '#555555',
}

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- Make tab colors match color scheme
local scheme_def = wezterm.color.get_builtin_schemes()[scheme]
config.colors = {
  tab_bar = {
    active_tab = {
      bg_color = scheme_def.background,
      fg_color = scheme_def.foreground,
    }
  }
}

return config