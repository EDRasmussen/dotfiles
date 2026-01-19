require("mason").setup()

require("mason-lspconfig").setup({
	ensure_installed = {
		"bashls",
		"gopls",
		"lua_ls",
		"phpactor",
		"vtsls",
		"vue_ls",
		"html",
		"cssls",
		"jsonls",
		"svelte",
		"pyright",
		"sqls",
	},
	automatic_installation = true,
})

require("mason-tool-installer").setup({
	ensure_installed = {
		"prettierd",
		"stylua",
		"gofumpt",
		"goimports",
		"eslint_d",
		"black",
		"csharpier",
		"isort",
		"sqlfluff",
		"php-cs-fixer",
		"php-debug-adapter",
	},
	auto_update = false,
	run_on_start = true,
})
