return {
	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			opts.formatters_by_ft.bzl = { "buildifier" }
			opts.formatters_by_ft.starlark = { "buildifier" }
		end,
	},
}
