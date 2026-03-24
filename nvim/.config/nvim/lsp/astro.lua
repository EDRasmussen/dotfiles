local mason_tsdk = vim.fn.expand(vim.fn.stdpath("data") .. "/mason/packages/astro-language-server/node_modules/typescript/lib")

local function resolve_tsdk(root_dir)
	if root_dir then
		local local_tsdk = root_dir .. "/node_modules/typescript/lib"
		if vim.uv.fs_stat(local_tsdk) then
			return local_tsdk
		end
	end

	return mason_tsdk
end

---@type vim.lsp.Config
return {
	cmd = { "astro-ls", "--stdio" },
	filetypes = { "astro" },
	root_markers = {
		"astro.config.mjs",
		"astro.config.js",
		"astro.config.ts",
		"package.json",
		"tsconfig.json",
		"jsconfig.json",
		".git",
	},
	init_options = {
		typescript = {
			tsdk = mason_tsdk,
		},
	},
	on_new_config = function(config, root_dir)
		config.init_options = config.init_options or {}
		config.init_options.typescript = config.init_options.typescript or {}
		config.init_options.typescript.tsdk = resolve_tsdk(root_dir)
	end,
}
