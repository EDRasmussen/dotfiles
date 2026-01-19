local util = require("conform.util")

require("conform").setup({
	formatters = {
		sqlfluff = {
			sqlfluff = {
				cwd = util.root_file({ ".sqlfluff", ".git", "compose.yaml", "go.mod" }),
			},
		},
	},
	formatters_by_ft = {
		cs = { "csharpier" },
		go = { "goimports", "gofmt" },
		php = { "php_cs_fixer" },
		gomod = { "gofmt" },
		gowork = { "gofmt" },
		lua = { "stylua" },
		python = { "isort", "black" },
		sql = { "sqlfluff" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		vue = { "prettierd", "prettier", stop_after_first = true },
		svelte = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		scss = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
		jsonc = { "prettierd", "prettier", stop_after_first = true },
		yaml = { "prettierd", "prettier", stop_after_first = true },
		yml = { "prettierd", "prettier", stop_after_first = true },
		markdown = { "prettierd", "prettier", stop_after_first = true },
		xml = { "prettierd", "prettier", stop_after_first = true },
	},
	format_on_save = {
		timeout_ms = 5000,
		lsp_format = "fallback",
	},
})
