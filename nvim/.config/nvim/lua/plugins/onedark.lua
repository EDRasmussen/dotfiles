vim.opt.background = "dark"
require("onedark").setup({
	style = "dark",
	highlights = {
		MiniCursorword = { bg = "$bg1", fmt = "NONE" },
		MiniCursorwordCurrent = { bg = "$bg1", fmt = "NONE" },
	},
})
require("onedark").load()
