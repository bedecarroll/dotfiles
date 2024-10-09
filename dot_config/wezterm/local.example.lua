local wezterm = require("wezterm")
local mux = wezterm.mux
local M = {}

-- Helper lua functions
function Startswith(str, prefix)
	return string.sub(str, 1, string.len(prefix)) == prefix
end

function M.apply_to_config(config)
	-- Make text clickable
	table.insert(config.hyperlink_rules, {
		regex = "[pPrR]{2}([0-9]{1,10})",
		format = "https://github.com/bedecarroll/dotfiles/pull/$1",
	})

	-- Open with browser
	config.quick_select_patterns = {
		-- The negative lookbehind is because of the vim chars
		"https?://\\S+(?<!¬)",
		"[pPrR]{2}[0-9]{1,10}",
	}
	table.insert(config.keys, {
		key = "t",
		mods = "CTRL|SHIFT",
		action = wezterm.action.QuickSelectArgs({
			label = "open url",
			action = wezterm.action_callback(function(window, pane)
				local selection = window:get_selection_text_for_pane(pane)
				wezterm.log_info("opening: " .. selection)
				if Startswith(selection, "pr") then
					selection = selection:gsub("pr", "")
					wezterm.open_with("https://github.com/bedecarroll/dotfiles/pull/" .. selection)
				else
					wezterm.open_with(selection)
				end
			end),
		}),
	})

	-- Startup settings
	wezterm.on("gui-startup", function()
		local window = mux.all_windows()[1]

		local tab_titles_and_paths = {
			{ "tab1" },
			{ "tab2" },
			{ "tab3", "/tmp/" },
		}

		for index, value in ipairs(tab_titles_and_paths) do
			if value[2] ~= nil then
				SPAWN_ARGS = { cwd = value[2] }
			else
				SPAWN_ARGS = { cwd = wezterm.home_dir }
			end
			if index ~= 1 then
				local new_tab = window:spawn_tab(SPAWN_ARGS)
				new_tab:set_title(value[1])
			else
				window:tabs()[1]:set_title(value[1])
			end
		end

		-- Default empty window
		window:spawn_tab({ cwd = wezterm.home_dir })
	end)
end

return M
