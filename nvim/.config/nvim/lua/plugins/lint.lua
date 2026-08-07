local lint = require("lint")

local function nearest_node_binary(name)
	local buffer_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	local node_modules = vim.fs.find("node_modules", {
		path = buffer_dir,
		upward = true,
		type = "directory",
	})[1]
	local executable = node_modules and vim.fs.joinpath(node_modules, ".bin", name)

	return executable and vim.fn.executable(executable) == 1 and executable or name
end

-- Resolve from the buffer instead of Neovim's cwd so nested apps in a monorepo
-- use their own ESLint installation and configuration.
lint.linters.eslint.cmd = function()
	return nearest_node_binary("eslint")
end

-- LSPs remain the primary source of compiler and type diagnostics. These
-- standalone linters add ecosystem-specific checks where they provide value;
-- Rust Clippy is already enabled through rust-analyzer.
lint.linters_by_ft = {
	astro = { "oxlint" },
	bash = { "shellcheck" },
	dockerfile = { "hadolint" },
	go = { "golangcilint" },
	javascript = { "oxlint" },
	javascriptreact = { "oxlint" },
	lua = { "luacheck" },
	markdown = { "markdownlint-cli2" },
	php = { "phpstan" },
	python = { "ruff" },
	sh = { "shellcheck" },
	sql = { "sqlfluff" },
	-- Svelte projects need template-aware parsing; use their local ESLint and
	-- eslint-plugin-svelte instead of Oxlint's script-block-only support.
	svelte = { "eslint" },
	typescript = { "oxlint" },
	typescriptreact = { "oxlint" },
	vue = { "oxlint" },
	yaml = { "yamllint" },
	ghaction = { "actionlint" },
}

-- Neovim is the expected runtime for Lua files in this configuration.
vim.list_extend(lint.linters.luacheck.args, { "--globals", "vim" })

local lint_group = vim.api.nvim_create_augroup("NvimLint", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
	group = lint_group,
	callback = function()
		lint.try_lint()
	end,
})

vim.keymap.set("n", "<leader>ll", function()
	lint.try_lint()
end, { desc = "Lint current buffer" })
