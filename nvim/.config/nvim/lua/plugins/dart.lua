require("dart").setup({
	buflist = {}, -- Only deliberate pins, not a growing list of recent files.
	tabline = {
		always_show = false,
		icons = true,
		max_item_len = 28,
		label_fg = "#737c8c",
		label_marked_fg = "#61afef",
	},
	mappings = {
		mark = "<leader>mm",
		jump = "<leader>j",
		pick = "<leader>mp",
		next = "",
		prev = "",
		unmark_all = "<leader>mu",
	},
})

local function style_dart()
	local bg = "#282c34"
	vim.api.nvim_set_hl(0, "DartFill", { bg = bg })
	for _, group in ipairs({ "DartCurrent", "DartVisible", "DartMarked", "DartMarkedCurrent" }) do
		local active = group:find("Current") ~= nil
		local text = { fg = active and "#abb2bf" or "#737c8c", bg = bg, bold = active }
		local label = { fg = active and "#61afef" or "#737c8c", bg = bg, bold = active }
		vim.api.nvim_set_hl(0, group, text)
		vim.api.nvim_set_hl(0, group .. "Label", label)
		vim.api.nvim_set_hl(0, group .. "Modified", { fg = "#e5c07b", bg = bg, bold = active })
		vim.api.nvim_set_hl(0, group .. "LabelModified", label)
	end
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("DartStyling", { clear = true }),
	callback = style_dart,
})
style_dart()
