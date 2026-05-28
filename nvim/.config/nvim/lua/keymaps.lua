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

vim.keymap.set("n", "<leader>gb", function()
	require("gitsigns").blame()
end, { desc = "Blame file (split)" })
vim.keymap.set("n", "<leader>gl", function()
	require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle inline blame" })
