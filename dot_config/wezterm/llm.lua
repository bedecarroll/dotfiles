local wezterm = require("wezterm")
local M, io, os, table = {}, io, os, table

local function call_helper(pane_id, text, question, new)
	-- write context into tmpfile
	local tmp = os.tmpname()
	local f = io.open(tmp, "w")
	if not f then
		wezterm.log_error("Failed to open temporary file: ", tmp)
		return nil, false, "Failed to open temporary file"
	end
	f:write(text)
	f:close()

	local helper = os.getenv("HOME") .. "/.local/bin/llm-from-wez"
	local args = { helper }
	if new then
		table.insert(args, "--new")
	end
	table.insert(args, tostring(pane_id))
	table.insert(args, tmp)
	table.insert(args, question)

	return wezterm.run_child_process(args) -- ok, stdout, stderr
end

function M.ask(win, pane, n, new)
	local act = wezterm.action
	local buf = (n and pane:get_lines_as_text(n)) or pane:get_lines_as_text()

	win:perform_action(
		act.PromptInputLine({
			description = "Ask LLM:",
			action = wezterm.action_callback(function(w, p, question)
				if not question or #question == 0 then
					return
				end

				local ok, out, err = call_helper(p:pane_id(), buf, question, new)
				if not ok then
					w:toast_notification("LLM error", err, nil, 6000)
					return
				end

				-- show reply in right-hand 45 % split
				local tmp_out = os.tmpname()
				local fo, err_open = io.open(tmp_out, "w")
				if not fo then
					w:toast_notification("Failed to open temp file", err_open or "unknown error", nil, 6000)
					return
				end
				fo:write(tostring(out))
				fo:close()

				w:perform_action(
					act.SplitPane({
						direction = "Right",
						size = { Percent = 45 },
						command = { args = { "bash", "-lc", "less -R " .. tmp_out } },
					}),
					p
				)
			end),
		}),
		pane
	)
end

function M.reset(pane_id)
	wezterm.run_child_process({
		os.getenv("HOME") .. "/.local/bin/llm-from-wez",
		"--new",
		tostring(pane_id),
		os.tmpname(),
		"",
	})
end

return M
