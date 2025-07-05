local wezterm = require("wezterm")
local llm = require("llm")
local M = {}

-- Helper lua functions
function Startswith(str, prefix)
	return string.sub(str, 1, string.len(prefix)) == prefix
end

function M.apply_to_config(config)
	config.term = "wezterm"

	-- Visible screen → ask → reply
	table.insert(config.keys, { key = "l", mods = "CTRL|ALT", action = wezterm.action.EmitEvent("LLM_VIEWPORT") })

	-- Prompt for N lines of history → ask → reply
	table.insert(config.keys, { key = "L", mods = "CTRL|ALT", action = wezterm.action.EmitEvent("LLM_SCROLLBACK") })

	-- Start *new* conversation for this pane
	table.insert(config.keys, { key = "N", mods = "CTRL|ALT", action = wezterm.action.EmitEvent("LLM_RESET") })

	wezterm.on("LLM_VIEWPORT", function(window, pane)
		llm.ask(window, pane, nil, false)
	end)

	wezterm.on("LLM_SCROLLBACK", function(window, pane)
		window:perform_action(
			wezterm.action.PromptInputLine({
				description = "Lines of scroll-back to send:",
				action = wezterm.action_callback(function(w, p, line)
					local n = tonumber(line or "")
					if n and n > 0 then
						llm.ask(w, p, n, false)
					end
				end),
			}),
			pane
		)
	end)

	wezterm.on("LLM_RESET", function(window, pane)
		llm.reset(pane:pane_id())
		window:toast_notification("LLM", "New conversation started for this pane", nil, 3000)
	end)
end

return M
