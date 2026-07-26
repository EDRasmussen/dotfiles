vim.diagnostic.config({ virtual_text = true })

-- Neovim pulls diagnostics only for the document that changed. For providers declaring
-- inter-file dependencies, also pull diagnostics for other visible documents after a save.
local interfile_diagnostics_group = vim.api.nvim_create_augroup(
	"LspInterfileDiagnostics",
	{ clear = true }
)
vim.api.nvim_create_autocmd("BufWritePost", {
	group = interfile_diagnostics_group,
	callback = function(args)
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
			local providers = {}
			client:_provider_foreach("textDocument/diagnostic", function(provider)
				if provider.interFileDependencies then
					providers[#providers + 1] = provider
				end
			end)

			if #providers > 0 then
				local refreshed = {}
				for _, window in ipairs(vim.api.nvim_list_wins()) do
					local bufnr = vim.api.nvim_win_get_buf(window)
					if
						bufnr ~= args.buf
						and client.attached_buffers[bufnr]
						and not refreshed[bufnr]
					then
						refreshed[bufnr] = true
						for _, provider in ipairs(providers) do
							client:request("textDocument/diagnostic", {
								identifier = provider.identifier,
								textDocument = vim.lsp.util.make_text_document_params(bufnr),
							}, nil, bufnr)
						end
					end
				end
			end
		end
	end,
})

-- nvim-ufo uses LSP folding ranges as its main fold provider
vim.lsp.config("*", {
	capabilities = {
		textDocument = {
			foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			},
		},
	},
})

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
