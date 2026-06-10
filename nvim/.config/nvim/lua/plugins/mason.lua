require("mason").setup()

require("mason-lspconfig").setup({
	ensure_installed = {
		"astro",
		"bashls",
		"clangd",
		"gopls",
		"lua_ls",
		"intelephense",
		"twiggy_language_server",
		"vtsls",
		"vue_ls",
		"html",
		"cssls",
		"jsonls",
		"svelte",
		"pyright",
		"rust_analyzer",
		"sqls",
		"tailwindcss",
	},
	automatic_installation = true,
})

	require("mason-tool-installer").setup({
	ensure_installed = {
		"prettierd",
		"mdx-analyzer",
		"stylua",
		"clang-format",
		"gofumpt",
		"goimports",
		"eslint_d",
		"black",
		"csharpier",
		"oxlint",
		"oxfmt",
		"isort",
		"sqlfluff",
		"php-cs-fixer",
		"djlint",
		"php-debug-adapter",
	},
	auto_update = false,
	run_on_start = true,
})
