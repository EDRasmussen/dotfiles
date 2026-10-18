-- Set NVIM_NO_ICONS=1 on machines without a Nerd Font.
local no_icons = vim.env.NVIM_NO_ICONS == "1"

local function status_icon(icon, is_active)
	return {
		function()
			return icon
		end,
		color = function()
			if not is_active() then
				return "Comment"
			end
		end,
	}
end

local function dart_files()
	local dart = package.loaded["dart"]
	if not dart then
		return ""
	end

	local files = {}
	for _, item in ipairs(dart.state()) do
		if #files == 4 then
			break
		end
		table.insert(files, vim.fn.fnamemodify(item.filename, ":t"))
	end
	return table.concat(files, " | "):gsub("%%", "%%%%")
end

require("lualine").setup({
	options = {
		theme = "auto",
		icons_enabled = not no_icons,
		section_separators = "",
		component_separators = "",
		globalstatus = true,
		disabled_filetypes = {
			statusline = { "snacks_dashboard" },
			winbar = { "NvimTree" },
		},
	},
	sections = {
		lualine_a = {},
		lualine_b = {
			"branch",
			{ "diff", symbols = no_icons and { added = "+", modified = "~", removed = "-" } or nil },
			{ "diagnostics", symbols = no_icons and { error = "E:", warn = "W:", info = "I:", hint = "H:" } or nil },
		},
		lualine_c = { { "filename", path = 1 } },
		lualine_x = {
			{ dart_files },
			status_icon(no_icons and "AI" or "󰚩", function()
				return vim.fn["copilot#Enabled"]() == 1
			end),
			status_icon(no_icons and "LSP" or "󰒋", function()
				return #vim.lsp.get_clients({ bufnr = 0 }) > 0
			end),
			status_icon(no_icons and "FMT" or "󰉣", function()
				local conform = package.loaded["conform"]
				return conform ~= nil and #conform.list_formatters(0) > 0
			end),
			status_icon(no_icons and "LINT" or "󰁨", function()
				local lint = package.loaded["lint"]
				return lint ~= nil and #(lint.linters_by_ft[vim.bo.filetype] or {}) > 0
			end),
		},
		lualine_y = {},
		lualine_z = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	inactive_winbar = {
		lualine_a = {
			{ "filename", path = 1 },
		},
	},
	extensions = { "mason" },
})
