local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font_size = 10.5
config.font = wezterm.font("JetBrainsMono NFM")
config.line_height = 1
config.enable_wayland = false

config.enable_tab_bar = false
config.enable_scroll_bar = false

config.window_background_opacity = 1
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"
config.window_padding = {
	top = 2,
	bottom = 2,
	left = 2,
	right = 2,
}
config.keys = {}
config.initial_cols = 100
config.initial_rows = 30
config.audible_bell = "Disabled"
config.warn_about_missing_glyphs = false

config.term = "xterm-256color"
config.color_scheme_dirs = { "/home/srch/.config/wezterm/colors" }
config.color_scheme = "wezterm-wal"

return config
