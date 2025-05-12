-- Additional Mason LSPs
return {
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"bash-language-server",
				"jq-lsp",
				"jinja-lsp",
			},
		},
	},
}
