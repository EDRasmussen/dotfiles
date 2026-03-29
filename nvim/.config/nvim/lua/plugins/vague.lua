require("vague").setup({})
vim.cmd("colorscheme vague")

vim.api.nvim_set_hl(0, "MiniCursorword", { link = "CursorLine" })
vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", { link = "CursorLine" })
vim.api.nvim_set_hl(0, "MatchParen", { link = "Visual" })
