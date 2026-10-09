vim.opt.background = "dark"
require("catppuccin").setup({
	flavour = "mocha",
	custom_highlights = function(colors)
		return {
			MiniCursorword = { bg = colors.surface0, underline = false },
			MiniCursorwordCurrent = { bg = colors.surface0, underline = false },
		}
	end,
})
vim.cmd.colorscheme("catppuccin-mocha")
