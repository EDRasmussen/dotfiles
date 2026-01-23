---@type vim.lsp.Config
return {
	cmd = { "tailwindcss-language-server", "--stdio" },
	filetypes = {
		"html",
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
	root_markers = {
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
