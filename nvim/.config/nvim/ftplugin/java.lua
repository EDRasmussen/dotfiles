local jdtls = require("jdtls")

local root_dir = vim.fs.root(
	0,
	{ "gradlew", "mvnw", "settings.gradle", "settings.gradle.kts", "build.gradle", "build.gradle.kts", "pom.xml", ".git" }
)
if not root_dir then
	return
end

local function mason_package_path(package_name)
	local ok, registry = pcall(require, "mason-registry")
	if not ok then
		return nil
	end

	local package_ok, package = pcall(registry.get_package, package_name)
	if not package_ok or not package:is_installed() then
		return nil
	end

	return package:get_install_path()
end

local function glob_paths(pattern)
	local matches = vim.fn.glob(pattern, true, true)
	return type(matches) == "table" and matches or {}
end

local function java_bundles()
	local bundles = {}

	local java_debug_path = mason_package_path("java-debug-adapter")
	if java_debug_path then
		vim.list_extend(bundles, glob_paths(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"))
	end

	local java_test_path = mason_package_path("java-test")
	if java_test_path then
		vim.list_extend(bundles, vim.tbl_filter(function(bundle)
			return not bundle:match("jacocoagent%.jar$")
		end, glob_paths(java_test_path .. "/extension/server/*.jar")))
	end

	return bundles
end

local function java_se_name(version)
	local major = version:match("^(%d+)")
	if not major then
		return nil
	end

	return major == "8" and "JavaSE-1.8" or "JavaSE-" .. major
end

local function sdkman_java_runtimes()
	local sdkman_dir = vim.env.SDKMAN_CANDIDATES_DIR or vim.fn.expand("~/.sdkman/candidates")
	local java_dir = sdkman_dir .. "/java"
	if vim.fn.isdirectory(java_dir) == 0 then
		return {}
	end

	local runtimes = {}
	local seen = {}
	local current_java_home = vim.env.JAVA_HOME and (vim.uv.fs_realpath(vim.env.JAVA_HOME) or vim.env.JAVA_HOME)
	for _, path in ipairs(vim.fn.glob(java_dir .. "/*", true, true)) do
		local version = vim.fn.fnamemodify(path, ":t")
		local runtime_path = vim.uv.fs_realpath(path) or path
		local name = version ~= "current" and java_se_name(version)
		if name and vim.fn.isdirectory(runtime_path) == 1 and not seen[runtime_path] then
			seen[runtime_path] = true
			table.insert(runtimes, {
				name = name,
				path = runtime_path,
				default = runtime_path == current_java_home,
			})
		end
	end

	return runtimes
end

local function map(lhs, rhs, desc, mode)
	vim.keymap.set(mode or "n", lhs, rhs, { buffer = true, desc = desc })
end

local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = vim.fs.normalize(vim.fn.stdpath("data") .. "/jdtls-workspaces/" .. project_name .. "-" .. vim.fn.sha256(root_dir))

jdtls.start_or_attach({
	cmd = { "jdtls", "-data", workspace_dir },
	root_dir = root_dir,
	settings = {
		java = {
			configuration = {
				runtimes = sdkman_java_runtimes(),
			},
			contentProvider = { preferred = "fernflower" },
			referencesCodeLens = { enabled = true },
			signatureHelp = { enabled = true },
		},
	},
	init_options = {
		bundles = java_bundles(),
	},
	on_attach = function()
		jdtls.setup_dap({ hotcodereplace = "auto" })
		require("jdtls.dap").setup_dap_main_class_configs()

		map("<leader>jo", jdtls.organize_imports, "Java organize imports")
		map("<leader>jv", jdtls.extract_variable, "Java extract variable", { "n", "v" })
		map("<leader>jc", jdtls.extract_constant, "Java extract constant", { "n", "v" })
		map("<leader>jm", function()
			jdtls.extract_method(true)
		end, "Java extract method", "v")
		map("<leader>dT", jdtls.test_class, "Debug Java test class")
		map("<leader>dM", jdtls.test_nearest_method, "Debug Java test method")
	end,
})
