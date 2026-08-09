---@type vim.lsp.Config
return {
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = { "html", "twig", "gotmpl" },
	root_markers = { "package.json", ".git" },
}
