local treesitter = require("nvim-treesitter")
require("nvim-treesitter").setup({
	lazy = false,
	build = ":TSUpdate",
	highlight = { enable = true },
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
			vim.treesitter.start(args.buf)
		end
	end,
})

local should_install = {
	"javascript",
	"typescript",
	"python",
	"c",
	"lua",
	"cpp",
	"svelte",
	"cs",
	"vue",
	"go",
	"sql",
	"html",
	"css",
	"json",
	"jsonc",
	"yaml",
	"yml",
	"markdown",
	"markdown_inline",
	"xml",
	"csv",
	"powershell",
	"vim",
	"vimdoc",
	"gitignore",
	"docker",
}

local installed = treesitter.get_installed()

local to_install = vim.tbl_filter(function(lang)
	return not vim.tbl_contains(installed, lang)
end, should_install)

treesitter.install(to_install)

require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true,
		selection_modes = {
			["@parameter.outer"] = "v",
			["@function.outer"] = "V",
			["@class.outer"] = "V",
		},
		include_surrounding_whitespace = true,
	},
	move = {
		set_jumps = false,
	},
})

vim.keymap.set({ "n", "x", "o" }, "]]", function()
	require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
	vim.cmd("normal! zz")
end)

vim.keymap.set({ "n", "x", "o" }, "[[", function()
	require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
	vim.cmd("normal! zz")
end)
