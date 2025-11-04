-- https://github.com/duminghui/nvim-cfg/blob/main/lua/plugins/lang.lua
return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				taplo = {
					root_markers = { ".git", ".taplo.toml", "taplo.toml" },
					root_dir = function(bufnr, on_dir)
						local server = "taplo"
						local markers = vim.lsp.config[server].root_markers
						local root = vim.fs.root(bufnr, function(name)
							return name:match("%.toml$") ~= nil
						end)
						root = root or vim.fs.root(bufnr, markers)
						return root and on_dir(root)
					end,
				},
			},
		},
	},
}
