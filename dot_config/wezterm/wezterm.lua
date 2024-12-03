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

config.color_scheme = "Catppuccin Mocha"

-- Maximize window by default
wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- Set right status
wezterm.on("update-status", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local override = ""
	if next(overrides) ~= nil then
		override = "F12"
	end

	local working_dir = pane:get_current_working_dir()
	local tab = pane:tab()
	local zoomed = ""
	if tab then
		for _, p in ipairs(tab:panes_with_info()) do
			if p.is_zoomed then
				zoomed = "Z"
			end
		end
	end
	if working_dir then
		window:set_right_status(wezterm.format({
			{ Text = override .. " " .. zoomed .. " " .. (working_dir.file_path or "") .. "  " },
		}))
	end
end)

-- Disable leader
wezterm.on("toggle-leader", function(window, _)
	local overrides = window:get_config_overrides() or {}
	if not overrides.leader then
		-- replace it with an "impossible" leader that will never be pressed
		overrides.leader = { key = "_", mods = "CTRL|ALT|SUPER" }
		overrides.colors = { background = "#100000" }
		overrides.window_background_opacity = 0.95
		wezterm.log_warn("[leader] clear")
	else
		-- restore to the main leader
		overrides.leader = nil
		overrides.colors = nil
		overrides.window_background_opacity = nil
		wezterm.log_warn("[leader] set")
	end
	window:set_config_overrides(overrides)
end)

-- Helper lua functions
function Startswith(str, prefix)
	return string.sub(str, 1, string.len(prefix)) == prefix
end

-- Options
-- https://github.com/wez/wezterm/issues/5990#issuecomment-2305416553
config.front_end = "WebGpu"
-- NOTE: you need resize for :maximize to work
config.window_decorations = "RESIZE"
config.enable_scroll_bar = true
config.window_padding = {
	left = "1cell",
	right = "1cell",
	top = "0.5cell",
	bottom = "0.5cell",
}
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.font = wezterm.font_with_fallback({ "Comic Mono", "JetBrains Mono" })
config.font_size = 16.0
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.8,
}
config.hide_tab_bar_if_only_one_tab = false
config.scrollback_lines = 30000
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Key maps
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 5000 } -- 5s timeout

-- Defaults so I don't forget
table.insert(keys, { key = "p", mods = "CTRL|SHIFT", action = wezterm.action.ActivateCommandPalette })
-- https://wezfurlong.org/wezterm/quickselect.html
-- This is to copy text
table.insert(keys, { key = " ", mods = "CTRL|SHIFT", action = wezterm.action.QuickSelect })
-- https://wezfurlong.org/wezterm/config/lua/config/quick_select_patterns.html
config.quick_select_patterns = {
	-- The negative lookbehind is because of the vim chars
	"https?://\\S+(?<!¬)",
}
-- https://wezfurlong.org/wezterm/config/lua/keyassignment/QuickSelectArgs.html
-- This is to launch selection
table.insert(keys, {
	key = "t",
	mods = "CTRL|SHIFT",
	action = wezterm.action.QuickSelectArgs({
		label = "open url",
		action = wezterm.action_callback(function(window, pane)
			local selection = window:get_selection_text_for_pane(pane)
			wezterm.log_info("opening: " .. selection)
			-- if Startswith(selection, "a") then
			--   selection = selection:gsub("-", ".")
			-- else
			--   wezterm.open_with(selection)
			-- end
			wezterm.open_with(selection)
		end),
	}),
})

-- General
-- table.insert(keys, { key = "a", mods = "LEADER|CTRL", action = act.SendString("\x01") })
table.insert(keys, { key = "r", mods = "LEADER", action = act.Search("CurrentSelectionOrEmptyString") })
table.insert(keys, { key = "[", mods = "LEADER|CTRL", action = act.CloseCurrentPane({ confirm = true }) })
table.insert(keys, { key = "F12", mods = "NONE", action = wezterm.action({ EmitEvent = "toggle-leader" }) })

-- Panes
table.insert(keys, { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) })
table.insert(keys, { key = "z", mods = "LEADER", action = act.TogglePaneZoomState })
table.insert(keys, { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) })
table.insert(keys, { key = "|", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) })
table.insert(keys, { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") })
table.insert(keys, { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") })
table.insert(keys, { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") })
table.insert(keys, { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") })
table.insert(keys, { key = "h", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) })
table.insert(keys, { key = "j", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) })
table.insert(keys, { key = "k", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) })
table.insert(keys, { key = "l", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) })

-- Tabs
table.insert(keys, { key = "w", mods = "LEADER", action = act.ShowTabNavigator })
table.insert(
	keys,
	{ key = "c", mods = "LEADER", action = act.SpawnCommandInNewTab({ domain = "CurrentPaneDomain", cwd = "~" }) }
)
table.insert(keys, { key = "7", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) })
table.insert(keys, { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) })
table.insert(keys, { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) })
for i = 1, 9 do
	table.insert(keys, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i - 1) })
end

config.keys = keys
config.enable_wayland = false

local local_exists, local_config = pcall(require, "local")
if local_exists then
	local_config.apply_to_config(config)
end
return config
