local wezterm = require("wezterm")
local act = wezterm.action

return {
	window_background_opacity = 1.0,

	initial_rows = 35,
	initial_cols = 150,

	default_prog = { "pwsh.exe", "-NoLogo" },

	window_decorations = "RESIZE",
	enable_tab_bar = false,

	color_scheme_dirs = { wezterm.home_dir },
	color_scheme = "tokyonight_moon",

	colors = {
		indexed = { [241] = "#65bcff" },
	},

	underline_thickness = 3,
	cursor_thickness = 4,
	underline_position = -6,
	enable_kitty_graphics = true,

	window_frame = {
		border_left_width = 0,
		border_right_width = 0,
		border_top_height = 0,
		border_bottom_height = 0,
	},

	window_padding = {
		left = "5pt",
		right = 0,
		top = "8pt",
		bottom = 0,
	},

	keys = {
		{ key = "q", mods = "CTRL|SHIFT", action = act.QuitApplication },
		{ key = "m", mods = "CTRL|SHIFT", action = act.Hide },
		{ key = "f", mods = "CTRL|SHIFT", action = act.ToggleFullScreen },
	},

	mouse_bindings = {
		{
			event = { Down = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = act.StartWindowDrag,
		},
		{
			event = { Down = { streak = 1, button = "Left" } },
			mods = "CTRL|SHIFT",
			action = act.StartWindowDrag,
		},
	},

	font = wezterm.font("JetBrains Mono"),
	bold_brightens_ansi_colors = true,
	font_rules = {
		{
			intensity = "Bold",
			italic = true,
			font = wezterm.font({ family = "Maple Mono", weight = "Bold", style = "Italic" }),
		},
		{
			italic = true,
			intensity = "Half",
			font = wezterm.font({ family = "Maple Mono", weight = "DemiBold", style = "Italic" }),
		},
		{
			italic = true,
			intensity = "Normal",
			font = wezterm.font({ family = "Maple Mono", style = "Italic" }),
		},
	},
}
