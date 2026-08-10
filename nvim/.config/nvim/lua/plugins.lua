vim.g.copilot_npx_command = 0

vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
	{ src = "https://github.com/davidmh/mdx.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/williamboman/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("^1"),
	},
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/mfussenegger/nvim-lint" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },

	{ src = "https://github.com/GustavEikaas/easy-dotnet.nvim" },

	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/nvim-mini/mini.nvim" },
	{ src = "https://github.com/iofq/dart.nvim" },
	{ src = "https://github.com/andymass/vim-matchup" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	-- Keep both colorschemes installed so switching back only requires changing
	-- the theme module below.
	{ src = "https://github.com/WTFox/luna.nvim" },
	{ src = "https://github.com/boningmaple/mac-clear" },

	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://codeberg.org/mfussenegger/nvim-jdtls" },
	{ src = "https://github.com/igorlfs/nvim-dap-view", version = vim.version.range("1.*") },
	{ src = "https://github.com/leoluz/nvim-dap-go" },
	{ src = "https://github.com/jay-babu/mason-nvim-dap.nvim" },
	{ src = "https://github.com/j-hui/fidget.nvim" },
	{ src = "https://github.com/github/copilot.vim" },
	{ src = "https://github.com/LunarVim/bigfile.nvim" },
	{ src = "https://github.com/folke/trouble.nvim" },
	{ src = "https://github.com/kevinhwang91/promise-async" },
	{ src = "https://github.com/kevinhwang91/nvim-ufo" },
	{ src = "https://github.com/luukvbaal/statuscol.nvim" },
})

vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

require("plugins.nvim-treesitter")
require("plugins.mason")
require("luasnip.loaders.from_vscode").lazy_load()
require("plugins.blink-cmp")
require("gitsigns").setup()
require("plugins.conform")
require("plugins.lint")
require("plugins.telescope")
require("plugins.easy-dotnet")
require("plugins.lualine")
require("plugins.mini")
require("plugins.dart")
require("plugins.luna")
-- To restore the previous theme, use this instead:
-- require("plugins.mac-clear")
require("plugins.dap")
require("plugins.statuscol")
require("plugins.ufo")
require("trouble").setup({
	modes = {
		symbols = {
			win = { position = "right", size = 50 },
		},
	},
})
require("fidget").setup({})

-- Use the local Owl checkout while the plugin is under development.
local owl_path = vim.fn.expand("~/projects/owl.nvim")
if vim.fn.isdirectory(owl_path) == 1 then
	vim.opt.runtimepath:prepend(owl_path)
	vim.cmd.runtime("plugin/owl.lua")
	require("owl").setup()
end
