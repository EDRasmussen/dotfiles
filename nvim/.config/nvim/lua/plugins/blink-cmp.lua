require("blink.cmp").setup({
	fuzzy = { implementation = "prefer_rust_with_warning" },
	snippets = { preset = "luasnip" },
	signature = { enabled = true },
	completion = {
		documentation = { auto_show = true, auto_show_delay_ms = 200 },
	},
	keymap = {
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<Up>"] = { "select_prev", "fallback" },
		["<CR>"] = { "accept", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	sources = { default = { "lsp", "snippets" } },
})
