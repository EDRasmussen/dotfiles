local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ timeout = 170 })
	end,
	group = highlight_group,
})

local cursorword_group = augroup("CursorwordTagAware", { clear = true })

local function get_capture_name(capture)
	if type(capture) == "string" then
		return capture
	end

	if type(capture) == "table" then
		return capture.capture or capture.name or capture[1]
	end
end

local function is_on_tag(bufnr)
	local pos = vim.api.nvim_win_get_cursor(0)
	local row = pos[1] - 1
	local col = pos[2]
	local ok, captures = pcall(vim.treesitter.get_captures_at_pos, bufnr, row, col)

	if not ok or type(captures) ~= "table" then
		return false
	end

	for _, capture in ipairs(captures) do
		local name = get_capture_name(capture)
		if type(name) == "string" and name:find("tag", 1, true) and not name:find("attribute", 1, true) then
			return true
		end
	end

	return false
end

autocmd("FileType", {
	pattern = { "html", "xml", "xhtml", "svelte", "vue", "javascriptreact", "typescriptreact" },
	callback = function(args)
		local bufnr = args.buf
		local function update_cursorword_mode()
			vim.b[bufnr].minicursorword_disable = is_on_tag(bufnr)
		end

		autocmd({ "BufEnter", "CursorMoved", "CursorMovedI" }, {
			buffer = bufnr,
			group = cursorword_group,
			callback = update_cursorword_mode,
		})

		update_cursorword_mode()
	end,
})
