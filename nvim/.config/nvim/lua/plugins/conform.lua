require("conform").setup({
	formatters_by_ft = {
		cs = { "csharpier" },
		go = { "goimports", "gofmt" },
		lua = { "stylua" },
		python = { "isort", "black" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		vue = { "prettierd", "prettier", stop_after_first = true },
		svelte = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
	},
	format_on_save = {
		timeout_ms = 5000,
		lsp_format = "fallback",
	},
})
