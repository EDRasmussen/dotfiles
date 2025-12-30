---@type vim.lsp.Config
return {
	cmd = { "sqls" },
	filetypes = { "sql" },
	root_dir = function(bufnr, _)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		return vim.fs.root(fname, {
			"sqls.yaml",
			"sqls.yml",
			"sqlc.yaml",
			"go.mod",
		})
	end,
}
