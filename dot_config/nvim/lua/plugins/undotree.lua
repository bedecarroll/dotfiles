-- UndoTree is great
return {
	{
		"mbbill/undotree",
		keys = {
			{ "<leader>u", "<cmd> UndotreeToggle<CR>", mode = "n", desc = "View Undo Tree" },
		},
		config = function()
			vim.g.undotree_SetFocusWhenToggle = 1
		end,
	},
}
