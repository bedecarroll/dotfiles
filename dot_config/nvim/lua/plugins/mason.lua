-- Additional Mason LSPs
return {
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"bash-language-server",
				"jinja-lsp",
				"jq-lsp",
				"oxlint",
				"buildifier",
				"starpls",
			},
		},
	},
}
