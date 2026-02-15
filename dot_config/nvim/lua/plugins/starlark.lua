return {
	"neovim/nvim-lspconfig",
	opts = function(_, opts)
		local util = require("lspconfig.util")
		local codex_rules = vim.fn.expand("~/.codex/rules")

		opts.servers = opts.servers or {}
		opts.servers.starpls = {
			filetypes = { "bzl", "starlark" },
			root_dir = function(bufnr, on_dir)
				local fname = vim.api.nvim_buf_get_name(bufnr)
				if fname == "" then
					return
				end
				local bazel_root =
					util.root_pattern("WORKSPACE", "WORKSPACE.bazel", "MODULE.bazel", ".git")(fname)
				if bazel_root then
					on_dir(bazel_root)
					return
				end
				if vim.startswith(fname, codex_rules .. "/") then
					on_dir(codex_rules)
				end
			end,
		}
	end,
}
