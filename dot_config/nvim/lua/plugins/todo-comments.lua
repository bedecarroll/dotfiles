return {
	{
		"folke/todo-comments.nvim",
		opts = {
			highlight = {
				pattern = {
					-- NOTE(xyz):
					[[.*<((KEYWORDS)%(\(.{-1,}\))?):]],
					-- TODO 123:
					[[.*<((KEYWORDS)%(\s+\d+)?):]],
				},
			},
		},
	},
}
