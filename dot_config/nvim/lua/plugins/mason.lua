-- Additional Mason LSPs
return {
	{
		"williamboman/mason.nvim",
		branch = "v1.x",
		opts = {
			ensure_installed = {
				"bash-language-server",
				"jq-lsp",
				"jinja-lsp",
			},
		},
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			branch = "v1.x",
		},
	},
}
