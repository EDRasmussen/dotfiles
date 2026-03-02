---@type vim.lsp.Config
local licence_file = vim.fn.expand("~/.config/intelephense/licence.txt")
local licence_key = nil
if vim.fn.filereadable(licence_file) == 1 then
	licence_key = vim.fn.readfile(licence_file)[1]
end

return {
	cmd = { "intelephense", "--stdio" },
	filetypes = { "php" },
	root_markers = { "composer.json", ".git" },
	init_options = {
		licenceKey = licence_key,
	},
}
