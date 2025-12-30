require("lualine").setup({
	options = {
		theme = "auto",
		section_separators = "",
		component_separators = "",
		globalstatus = true,
	},
	sections = {
		lualine_c = {
			{ "filename", path = 1 },
		},
	},
	inactive_winbar = {
		lualine_a = {
			{
				"filename",
				path = 1,
			},
		},
	},
})
