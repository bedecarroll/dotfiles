local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

local config = {}
local keys = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Maximize window by default
wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- Options
-- config.color_scheme = "Gruvbox (Gogh)"
-- config.default_cursor_style = "SteadyBlock"
-- config.cursor_blink_rate = 0
config.window_decorations = "RESIZE"
config.enable_scroll_bar = true
config.window_padding = {
	left = "0",
	right = "0",
	top = "0",
	bottom = "0",
}
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.font_size = 14.0
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.8,
}
config.hide_tab_bar_if_only_one_tab = false
-- config.tab_max_width = 32
config.scrollback_lines = 30000

-- Key maps
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 5000 } -- 5s timeout

-- General
-- table.insert(keys, { key = "a", mods = "LEADER|CTRL", action = act.SendString("\x01") })
table.insert(keys, { key = "r", mods = "LEADER", action = act.Search("CurrentSelectionOrEmptyString") })

-- Panes
table.insert(keys, { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) })
table.insert(keys, { key = "z", mods = "LEADER", action = act.TogglePaneZoomState })
table.insert(keys, { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) })
table.insert(keys, { key = "|", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) })
table.insert(keys, { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") })
table.insert(keys, { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") })
table.insert(keys, { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") })
table.insert(keys, { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") })
table.insert(keys, { key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) })
table.insert(keys, { key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) })
table.insert(keys, { key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) })
table.insert(keys, {
	key = "L",
	mods = "LEADER|SHIFT",
	action = act.AdjustPaneSize({ "Right", 5 }),
})

-- Tabs
table.insert(keys, { key = "w", mods = "LEADER", action = act.ShowTabNavigator })
table.insert(
	keys,
	{ key = "c", mods = "LEADER", action = act.SpawnCommandInNewTab({ domain = "CurrentPaneDomain", cwd = "~" }) }
)
table.insert(keys, { key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) })
table.insert(keys, { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) })
table.insert(keys, { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) })
for i = 1, 8 do
	table.insert(keys, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i - 1) })
end

config.keys = keys

local local_config = require("local")
local_config.apply_to_config(config)
return config
