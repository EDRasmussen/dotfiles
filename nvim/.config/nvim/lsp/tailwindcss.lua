---@type vim.lsp.Config
return {
	cmd = { "tailwindcss-language-server", "--stdio" },
	filetypes = {
		"astro",
		"html",
		"gotmpl",
		"twig",
		"css",
		"scss",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"vue",
		"svelte",
		"php",
	},
	settings = {
		tailwindCSS = {
			includeLanguages = {
				gotmpl = "html",
			},
		},
	},
	root_markers = {
		"package.json",
		".git",
		"astro.config.mjs",
		"astro.config.js",
		"astro.config.ts",
		"tailwind.config.js",
		"tailwind.config.ts",
		"tailwind.config.mjs",
		"tailwind.config.cjs",
		"postcss.config.js",
		"postcss.config.cjs",
		"postcss.config.mjs",
		"svelte.config.js",
		"vite.config.ts",
		"vite.config.js",
	},
}
