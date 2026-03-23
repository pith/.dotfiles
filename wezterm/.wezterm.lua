-- Pull in the wezterm API
local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 12

config.window_decorations = "RESIZE"

config.window_background_opacity = 0.95
config.macos_window_background_blur = 10

config.color_scheme = "Catppuccin Mocha"
-- config.colors = {
--   foreground = "#CBE0F0",
--   background = "#011423",
--   cursor_bg = "#47FF9C",
--   cursor_border = "#47FF9C",
--   cursor_fg = "#011423",
--   selection_bg = "#033259",
--   selection_fg = "#CBE0F0",
--   ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
--   brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
-- }

config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

config.colors = {
  tab_bar = {
    background = "#1e1e2e",
    active_tab = {
      bg_color = "#45475a",
      fg_color = "#cdd6f4",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#1e1e2e",
      fg_color = "#6c7086",
    },
    inactive_tab_hover = {
      bg_color = "#313244",
      fg_color = "#89b4fa",
    },
  },
}

local act = wezterm.action

config.keys = {
  -- Pane splitting (vim-inspired)
  { key = "s", mods = "CTRL|ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "v", mods = "CTRL|ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

  -- Pane navigation (vim-like hjkl)
  { key = "h", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Right") },

  -- Tab management
  { key = "t", mods = "CTRL|ALT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "CTRL|ALT", action = act.CloseCurrentTab({ confirm = true }) },
  { key = "n", mods = "CTRL|ALT", action = act.ActivateTabRelative(1) },
  { key = "p", mods = "CTRL|ALT", action = act.ActivateTabRelative(-1) },
  { key = "1", mods = "CTRL|ALT", action = act.ActivateTab(0) },
  { key = "2", mods = "CTRL|ALT", action = act.ActivateTab(1) },
  { key = "3", mods = "CTRL|ALT", action = act.ActivateTab(2) },
  { key = "4", mods = "CTRL|ALT", action = act.ActivateTab(3) },
  { key = "5", mods = "CTRL|ALT", action = act.ActivateTab(4) },
  { key = "6", mods = "CTRL|ALT", action = act.ActivateTab(5) },
  { key = "7", mods = "CTRL|ALT", action = act.ActivateTab(6) },
  { key = "8", mods = "CTRL|ALT", action = act.ActivateTab(7) },
  { key = "9", mods = "CTRL|ALT", action = act.ActivateTab(8) },
}

return config
