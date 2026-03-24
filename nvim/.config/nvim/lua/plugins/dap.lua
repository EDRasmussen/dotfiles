local dap, dapui = require("dap"), require("dapui")

local function cargo_package_name(cwd)
	local cargo_toml = cwd .. "/Cargo.toml"
	if vim.fn.filereadable(cargo_toml) == 0 then
		return nil
	end

	local in_package = false
	for _, line in ipairs(vim.fn.readfile(cargo_toml)) do
		if line:match("^%s*%[package%]%s*$") then
			in_package = true
		elseif line:match("^%s*%[.+%]%s*$") then
			in_package = false
		elseif in_package then
			local name = line:match('^%s*name%s*=%s*"(.-)"')
			if name and name ~= "" then
				return name
			end
		end
	end

	return nil
end

local function rust_debug_program()
	local cwd = vim.fn.getcwd()
	local package_name = cargo_package_name(cwd)
	if not package_name then
		return vim.fn.input("Path to executable: ", cwd .. "/target/debug/", "file")
	end

	local program = string.format("%s/target/debug/%s", cwd, package_name)
	if vim.fn.filereadable(program) == 0 then
		vim.notify("Building Rust crate before debug...", vim.log.levels.INFO)
		vim.fn.system("cargo build --quiet")
		if vim.v.shell_error ~= 0 then
			vim.notify("cargo build failed. Pick executable manually.", vim.log.levels.WARN)
			return vim.fn.input("Path to executable: ", cwd .. "/target/debug/", "file")
		end
	end

	return program
end

dapui.setup()
dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

require("mason-nvim-dap").setup({
	automatic_installation = true,
	ensure_installed = {
		"delve",
		"codelldb",
		"js",
		"php",
	},
})

dap.adapters.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
		args = { "--port", "${port}" },
	},
}

dap.adapters.php = {
	type = "executable",
	command = "node",
	args = { vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js" },
}

dap.configurations.php = {
	{
		type = "php",
		request = "launch",
		name = "Listen for Xdebug",
		port = 9003,
	},
}

dap.configurations.rust = {
	{
		type = "codelldb",
		request = "launch",
		name = "Launch current crate",
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		program = rust_debug_program,
	},
}

require("dap-go").setup()

vim.keymap.set("n", "<F5>", dap.continue)
vim.keymap.set("n", "<F2>", dap.step_over)
vim.keymap.set("n", "<F1>", dap.step_into)
vim.keymap.set("n", "<F3>", dap.step_out)
vim.keymap.set("n", "<F10>", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>dr", dap.repl.open)
vim.keymap.set("n", "<leader>dl", dap.run_last)
