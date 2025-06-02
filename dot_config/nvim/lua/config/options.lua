-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- LSP Server to use for Python.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"

-- Set leader back to default
vim.g.mapleader = "\\"

-- NOTE: A lot of this comes from old vim, may be duplicate

-- Auto change dir to current file
vim.opt.autochdir = true

-- Start searching as you type
vim.opt.incsearch = true
-- Highlight search results
vim.opt.hlsearch = true
-- Ignore case in searches
vim.opt.ignorecase = true
-- Switch to case sensitive search if capitals are used
vim.opt.smartcase = true

-- Show a column where the cursor is (great for making sure things are at the
-- same level)
vim.opt.cursorcolumn = true

-- Reread when underlying file changes
vim.opt.autoread = true

-- Autosave when switching buffers
vim.opt.autowriteall = true

-- Line wrap
vim.opt.wrap = true

-- Highlight characters
vim.opt.list = true
vim.opt.listchars:append({ eol = "¬", tab = "|=", trail = "·" })

-- Splits open on the right
vim.opt.splitright = true

-- Enable undofiles
vim.opt.undofile = true

-- Delete comment character when joining commented lines
vim.opt.formatoptions:append({ "j" })

-- Set default indent
vim.opt.expandtab = true -- expand tabs into spaces
vim.opt.shiftwidth = 2 -- when indenting with '>', use 2 spaces width
vim.opt.softtabstop = 2 -- paste tabs
vim.opt.tabstop = 2 -- number of spaces a TAB counts for
vim.opt.autoindent = true -- copy indent from current line when starting a new line

-- Disable folding by default
vim.opt.foldenable = false

-- Disable mouse
vim.opt.mouse = ""

-- Disable system clipboard sync
-- Use + or * registers
vim.opt.clipboard = ""
