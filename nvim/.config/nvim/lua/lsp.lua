vim.diagnostic.config({ virtual_text = true })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		local map = function(mode, lhs, rhs)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
		end

		map("n", "<leader>gd", vim.lsp.buf.definition)
		map("n", "<leader>gD", vim.lsp.buf.declaration)
		map("n", "<leader>gr", vim.lsp.buf.references)
		map("n", "<leader>gi", vim.lsp.buf.implementation)
		map("n", "<leader>gt", vim.lsp.buf.type_definition)

		map("n", "<leader>rn", vim.lsp.buf.rename)
		map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action)

		map("n", "<C-w>d", vim.diagnostic.open_float)
	end,
})

vim.lsp.enable({
	"bashls",
	"gopls",
	"lua_ls",
	"phpactor",
	"twiggy",
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
})
