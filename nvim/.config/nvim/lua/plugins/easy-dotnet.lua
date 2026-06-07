local dotnet = require("easy-dotnet")

dotnet.setup({
	lsp = {
		config = dofile(vim.fn.stdpath("config") .. "/lsp/easy_dotnet.lua"),
	},
	debugger = {
		auto_register_dap = true,
		console = "integratedTerminal",
		apply_value_converters = true,
	},
})

local function dotnet_command(args)
	return function()
		vim.cmd("Dotnet " .. args)
	end
end

vim.keymap.set("n", "<leader>dd", dotnet_command("debug"), { desc = "Debug .NET project" })
vim.keymap.set("n", "<leader>dD", dotnet_command("debug default"), { desc = "Debug default .NET project" })
vim.keymap.set("n", "<leader>da", dotnet_command("debug attach"), { desc = "Attach .NET debugger" })
vim.keymap.set("n", "<leader>ds", dotnet_command("testrunner"), { desc = "Toggle .NET test runner" })
