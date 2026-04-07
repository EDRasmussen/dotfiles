require("gruvbox").setup({
	transparent_mode = true,
	italic = {
		comments = true,
	},
})

vim.cmd("colorscheme gruvbox")

vim.api.nvim_set_hl(0, "MiniCursorword", { link = "CursorLine" })
vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", { link = "CursorLine" })
vim.api.nvim_set_hl(0, "MatchParen", { link = "Visual" })
