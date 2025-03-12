return {
	{
		"folke/snacks.nvim",
		opts = function(_, opts)
			table.insert(
				opts.dashboard.preset.keys,
				#opts.dashboard.preset.keys,
				{ icon = "󰫺 ", key = "m", desc = "Mason", action = ":Mason" }
			)
		end,
	},
}
