vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.guicursor = "i:block" -- block cursor in insert mode
opt.colorcolumn = "100" -- highlight column 80
opt.signcolumn = "yes:1" -- always show sign column
opt.termguicolors = true -- enable true colors
opt.ignorecase = true -- ignore case in search
opt.swapfile = false -- disable swap files
opt.autoindent = true -- enable auto indentation
opt.smartindent = true -- enable smart indent
opt.expandtab = true -- use spaces instead of tabs
opt.tabstop = 4 -- number of spaces for a tab
opt.softtabstop = 4 -- number of spaces for a tab when editing
opt.shiftwidth = 4 -- number of spaces for autoindent
opt.shiftround = true -- round indent to multiple of shiftwidth
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" } -- characters to show
opt.list = true -- show whitespace characters
opt.number = true -- show line numbers
opt.relativenumber = true -- show relative line numbers
opt.numberwidth = 2 -- width of the line number column
opt.wrap = false -- disable line wrapping
opt.cursorline = true -- highlight current line
opt.scrolloff = 8 -- keep 8 lines above and below cursor
opt.inccommand = "nosplit" -- show the effects of a command in the buffer
opt.undodir = os.getenv("HOME") .. "/.nvim/undodir" -- dir for undo file
opt.undofile = true -- persistent undo file
opt.completeopt = { "menuone", "popup", "noinsert" }
opt.winborder = "rounded" -- use rounded borders for windows
opt.hlsearch = false -- disable highlight of search results
opt.splitright = true -- moves the cursor on vertical split
opt.splitbelow = true -- moves the cursor on horizontal split

vim.cmd.filetype("plugin indent on")

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)
