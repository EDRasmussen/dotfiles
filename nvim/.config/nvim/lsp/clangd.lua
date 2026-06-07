---@type vim.lsp.Config
return {
	cmd = { "clangd" },
	filetypes = { "c", "cpp", "objc", "objcpp" },
	init_options = {
		fallbackFlags = {
			"-Wall",
			"-Wextra",
			"-Wpedantic",
			"-Wconversion",
			"-Wsign-conversion",
		},
	},
	root_markers = {
		"compile_commands.json",
		"compile_flags.txt",
		"Makefile",
		"configure.ac",
		".clangd",
		".git",
	},
}
