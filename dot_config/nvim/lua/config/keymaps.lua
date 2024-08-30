-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Buffer selector
vim.keymap.set("n", "<Enter><Enter>", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })

-- NOTE: A lot of this comes from old vim, may be duplicate

-- Disable search highlight by hitting enter
vim.keymap.set("n", "<CR>", ":nohlsearch<CR>", { noremap = true, silent = true })

-- Disable arrow keys
vim.keymap.set("n", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<Right>", "<Nop>", { noremap = true, silent = true })

-- Insert newline without going into insert mode
-- https://stackoverflow.com/a/16136133
--vim.keymap.set("n", "oo", "o<Esc>k", { noremap = true, silent = true })
--vim.keymap.set("n", "OO", "O<Esc>j", { noremap = true, silent = true })
