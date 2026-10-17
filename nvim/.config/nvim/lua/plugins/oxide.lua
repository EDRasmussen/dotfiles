vim.opt.background = "dark"
require("oxide").setup({
	on_highlights = function(highlights, colors)
		highlights.MiniCursorword = { bg = colors.surface0, underline = false }
		highlights.MiniCursorwordCurrent = { bg = colors.surface0, underline = false }
	end,
})
vim.cmd.colorscheme("oxide")
