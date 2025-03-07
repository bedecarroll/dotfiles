-- UndoTree is great
return {
	{
		"mbbill/undotree",
		keys = { { "<leader>r", "<cmd>UndotreeToggle<cr>", desc = "View Undo Tree" } },
		lazy = false,
		config = function()
			vim.g.undotree_SetFocusWhenToggle = 1
		end,
	},
}
