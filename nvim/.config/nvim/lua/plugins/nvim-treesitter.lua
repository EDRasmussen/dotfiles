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
	"c_sharp",
	"vue",
	"go",
	"sql",
	"html",
	"css",
	"json",
	"yaml",
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
			["@function.inner"] = "V",
			["@class.outer"] = "V",
			["@class.inner"] = "V",
		},
		include_surrounding_whitespace = false,
	},
	move = {
		set_jumps = false,
	},
})
vim.keymap.set({ "x", "o" }, "af", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "if", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ac", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ic", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]f", function()
	require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]c", function()
	require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[f", function()
	require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[c", function()
	require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
end)
