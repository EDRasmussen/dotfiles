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

-- easy-dotnet's default root finder rejects paths that do not exist yet, so
-- Roslyn only attaches to a new :edit Foo.cs buffer after it has been written
-- and reopened. Resolve the project from the new file's parent directory.
local default_root_dir = vim.lsp.config.easy_dotnet.root_dir
vim.lsp.config("easy_dotnet", {
	root_dir = function(bufnr, on_dir)
		local path = vim.api.nvim_buf_get_name(bufnr)
		if path:match("^%a+://") or vim.fn.filereadable(path) == 1 then
			return default_root_dir(bufnr, on_dir)
		end

		local root = vim.fs.root(vim.fs.dirname(path), function(name)
			return name:match("%.slnx?$") or name:match("%.csproj$")
		end)
		on_dir(root)
	end,
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
