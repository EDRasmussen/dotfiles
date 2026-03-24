---@type vim.lsp.Config
return {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", "rust-project.json", ".git" },
	settings = {
		["rust-analyzer"] = {
			cargo = {
				allFeatures = true,
				loadOutDirsFromCheck = true,
				runBuildScripts = true,
			},
			check = {
				command = "clippy",
			},
			procMacro = {
				enable = true,
			},
			inlayHints = {
				bindingModeHints = { enable = true },
				closingBraceHints = { minLines = 1 },
				closureReturnTypeHints = { enable = "always" },
				lifetimeElisionHints = { enable = "skip_trivial", useParameterNames = true },
				parameterHints = { enable = true },
				reborrowHints = { enable = "always" },
				renderColons = true,
				typeHints = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
			},
			lens = {
				enable = true,
				references = {
					adt = { enable = true },
					enumVariant = { enable = true },
					method = { enable = true },
					trait = { enable = true },
				},
			},
		},
	},
}
