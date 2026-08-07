require("luna").setup({})
vim.cmd.colorscheme("luna")

-- Preserve the small highlight tweaks from the previous theme configuration.
vim.api.nvim_set_hl(0, "MiniCursorword", { link = "CursorLine" })
vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", { link = "CursorLine" })
vim.api.nvim_set_hl(0, "MatchParen", { link = "Visual" })
