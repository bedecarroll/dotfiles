-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- https://github.com/dpetka2001/dotfiles/blob/43ecf1a6c1f1c8bf4ffe6fbc591f46db25b592db/dot_config/nvim/lua/config/autocmds.lua#L31-L44
vim.api.nvim_create_augroup("myfmtoptions", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
	pattern = { "*" },
	callback = function()
		vim.opt.formatoptions = vim.opt.formatoptions
			+ {
				o = false, -- Don't continue comments with o and O
				r = false, -- Don't continue comments in insert mode
			}
	end,
	group = "myfmtoptions",
	desc = "Override format options",
})
