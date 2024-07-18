-- Additional Mason LSPs
return {
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"bash-language-server",
				"jq-lsp",
				"jinja-lsp",
			},
		},
	},
}
