local dap = require("dap")
local dap_view = require("dap-view")
local dap_go = require("dap-go")
local dap_utils = require("dap.utils")

local function notify_dap(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "DAP" })
end

local function input_executable(prompt, default_dir)
	return vim.fn.input(prompt, default_dir, "file")
end

local function path_join(...)
	return vim.fs.normalize(table.concat({ ... }, "/"))
end

local function cargo_metadata(cwd)
	local result = vim.system({ "cargo", "metadata", "--format-version", "1", "--no-deps" }, {
		cwd = cwd,
		text = true,
	}):wait()
	if result.code ~= 0 or not result.stdout or result.stdout == "" then
		return nil
	end

	local ok, decoded = pcall(vim.json.decode, result.stdout)
	if not ok then
		return nil
	end

	return decoded
end

local function rust_target_candidates(cwd)
	local metadata = cargo_metadata(cwd)
	if not metadata then
		return {}
	end

	local current_buffer = vim.api.nvim_buf_get_name(0)
	local candidates = {}
	for _, package in ipairs(metadata.packages or {}) do
		local package_root = vim.fs.dirname(package.manifest_path)
		local in_package = cwd == metadata.workspace_root or vim.startswith(cwd, package_root)
		if in_package then
			for _, target in ipairs(package.targets or {}) do
				local kind = target.kind and target.kind[1]
				if kind == "bin" or kind == "example" then
					local program = kind == "example"
						and path_join(metadata.target_directory, "debug", "examples", target.name)
						or path_join(metadata.target_directory, "debug", target.name)

					table.insert(candidates, {
						build_args = kind == "example"
							and { "build", "--quiet", "--package", package.name, "--example", target.name }
							or { "build", "--quiet", "--package", package.name, "--bin", target.name },
						cwd = metadata.workspace_root,
						kind = kind,
						label = string.format("%s (%s, %s)", target.name, package.name, kind),
						package = package.name,
						program = program,
						source = target.src_path,
					})
				end
			end
		end
	end

	local preferred = vim.iter(candidates):filter(function(candidate)
		return candidate.source == current_buffer
	end):totable()
	if #preferred == 1 then
		return preferred
	end

	return candidates
end

local function select_rust_target(candidates)
	if #candidates == 0 then
		return nil
	end

	if #candidates == 1 then
		return candidates[1]
	end

	local options = { "Select Rust debug target:" }
	for index, candidate in ipairs(candidates) do
		table.insert(options, string.format("%d. %s", index, candidate.label))
	end

	local choice = vim.fn.inputlist(options)
	if choice < 1 or choice > #candidates then
		return nil
	end

	return candidates[choice]
end

local function build_rust_target(target)
	notify_dap("Building Rust target " .. target.label .. "...")
	local result = vim.system(vim.list_extend({ "cargo" }, target.build_args), {
		cwd = target.cwd,
		text = true,
	}):wait()
	if result.code ~= 0 then
		notify_dap("cargo build failed. Pick executable manually.", vim.log.levels.WARN)
		return nil
	end

	return target.program
end

local function rust_debug_program()
	local cwd = vim.fn.getcwd()
	local target = select_rust_target(rust_target_candidates(cwd))
	if not target then
		return input_executable("Path to executable: ", path_join(cwd, "target", "debug") .. "/")
	end

	local program = build_rust_target(target)
	if not program or vim.fn.filereadable(program) == 0 then
		notify_dap("Built target but executable was not found. Pick it manually.", vim.log.levels.WARN)
		return input_executable("Path to executable: ", path_join(cwd, "target", "debug") .. "/")
	end

	return program
end

local function native_debug_program()
	return input_executable("Path to executable: ", vim.fn.getcwd() .. "/")
end

dap_view.setup({
	auto_toggle = "keep_terminal",
	follow_tab = true,
	winbar = {
		default_section = "scopes",
		controls = {
			enabled = true,
		},
	},
	windows = {
		position = "right",
		size = 0.33,
		terminal = {
			position = "below",
			size = 0.40,
		},
	},
})

dap.defaults.fallback.switchbuf = "usevisible,usetab,newtab"

dap.listeners.before.launch.dap_status = function()
	notify_dap("Starting debug session...")
end

dap.listeners.after.event_initialized.dap_status = function()
	notify_dap("Debugger attached")
end

dap.listeners.after.event_stopped.dap_status = function(session, body)
	local reason = body and body.reason or "breakpoint"
	notify_dap("Paused: " .. reason)
end

dap.listeners.after.event_continued.dap_status = function()
	notify_dap("Continued")
end

dap.listeners.before.disconnect.dap_status = function()
	notify_dap("Debugger disconnected")
end

dap.listeners.before.event_terminated.dap_status = function()
	notify_dap("Debug session terminated")
end

dap.listeners.before.event_exited.dap_status = function()
	notify_dap("Debug process exited")
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

dap.adapters.lldb = dap.adapters.codelldb

dap.adapters.cppdbg = dap.adapters.codelldb

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
		runInTerminal = true,
		program = rust_debug_program,
	},
	{
		type = "codelldb",
		request = "attach",
		name = "Attach to process",
		cwd = "${workspaceFolder}",
		pid = dap_utils.pick_process,
	},
}

local native_launch_configurations = {
	{
		type = "codelldb",
		request = "launch",
		name = "Launch executable",
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		program = native_debug_program,
	},
	{
		type = "codelldb",
		request = "attach",
		name = "Attach to process",
		cwd = "${workspaceFolder}",
		pid = dap_utils.pick_process,
	},
}

dap.configurations.cpp = native_launch_configurations

dap.configurations.c = native_launch_configurations

dap_go.setup({
	dap_configurations = {
		{
			type = "go",
			name = "Attach remote",
			mode = "remote",
			request = "attach",
		},
	},
})

vim.keymap.set("n", "<F5>", dap.continue)
vim.keymap.set("n", "<F6>", dap.terminate)
vim.keymap.set("n", "<F2>", dap.step_over)
vim.keymap.set("n", "<F1>", dap.step_into)
vim.keymap.set("n", "<F3>", dap.step_out)
vim.keymap.set("n", "<F10>", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>dt", dap.terminate)
vim.keymap.set("n", "<leader>dq", dap.disconnect)
vim.keymap.set("n", "<leader>du", dap_view.toggle)
vim.keymap.set("n", "<leader>dw", dap_view.add_expr)
vim.keymap.set("n", "<leader>dh", dap_view.hover)
vim.keymap.set("n", "<leader>dr", dap.repl.toggle)
vim.keymap.set("n", "<leader>dl", dap.run_last)
vim.keymap.set("n", "<leader>dc", dap.continue)
vim.keymap.set("n", "<leader>dn", function()
	dap.continue({ new = true })
end)
vim.keymap.set("n", "<leader>dT", dap_go.debug_test)
vim.keymap.set("n", "<leader>dL", dap_go.debug_last_test)
