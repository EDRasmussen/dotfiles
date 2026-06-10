vim.diagnostic.config({ virtual_text = true })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		local map = function(mode, lhs, rhs)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
		end

		local builtin = require("telescope.builtin")
		map("n", "<leader>gd", builtin.lsp_definitions)
		map("n", "<leader>gD", vim.lsp.buf.declaration)
		map("n", "<leader>gr", builtin.lsp_references)
		map("n", "<leader>gi", builtin.lsp_implementations)
		map("n", "<leader>gt", builtin.lsp_type_definitions)

		map("n", "<leader>rn", vim.lsp.buf.rename)
		map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action)

		map("n", "<C-w>d", vim.diagnostic.open_float)
	end,
})

vim.lsp.enable({
	"astro",
	"mdx",
	"bashls",
	"clangd",
	"gopls",
	"lua_ls",
	"intelephense",
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
