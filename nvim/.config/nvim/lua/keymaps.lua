local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fh", builtin.help_tags)
vim.keymap.set("n", "<leader>fd", builtin.diagnostics)

vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({
		async = true,
		lsp_format = "fallback",
	})
end, { desc = "Format file or selection" })

vim.keymap.set("n", "<leader>e", ":Explore<CR>", { desc = "Open file explorer" })

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xp", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Project diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle<cr>", { desc = "Symbols outline (Trouble)" })
vim.keymap.set("n", "<leader>xl", "<cmd>Trouble lsp toggle<cr>", { desc = "LSP definitions/references (Trouble)" })
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix list (Trouble)" })

vim.keymap.set("n", "<leader>gb", function()
	require("gitsigns").blame()
end, { desc = "Blame file (split)" })
vim.keymap.set("n", "<leader>gl", function()
	require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle inline blame" })
