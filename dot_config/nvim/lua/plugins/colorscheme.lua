-- Set colorscheme
return {
	-- add gruvbox
	{ "ellisonleao/gruvbox.nvim" },

	-- Configure LazyVim to change colorscheme
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "gruvbox",
		},
	},
}
