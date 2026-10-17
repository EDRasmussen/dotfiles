-- Classic Visual Studio 2012–2015 colors, without modern Dark+ accents.
local function set_style(style)
  local dark = style == "dark"
  local text = dark and "#dcdcdc" or "#000000"
  local cursorline = dark and "#282828" or "#f0f0f0"
  local groups = {
    MiniCursorword = { bg = cursorline, underline = false },
    MiniCursorwordCurrent = { bg = cursorline, underline = false },
  }

  for _, group in ipairs({
    "Function",
    "@function",
    "@function.builtin",
    "@function.macro",
    "@function.method",
    "@constant",
    "@constant.macro",
    "@attribute",
    "@label",
  }) do
    groups[group] = { fg = text }
  end

  require("vscode").setup({
    style = style,
    transparent = false,
    italic_comments = false,
    terminal_colors = true,
    color_overrides = {
      vscBack = dark and "#1e1e1e" or "#ffffff",
      vscFront = text,
      vscTabCurrent = dark and "#1e1e1e" or "#ffffff",
      vscLeftDark = dark and "#252526" or "#f3f3f3",
      vscPopupBack = dark and "#252526" or "#f3f3f3",
      vscCursorDarkDark = cursorline,
      vscGreen = dark and "#608b4e" or "#008000",
      vscPink = dark and "#569cd6" or "#0000ff",
      vscLightBlue = text,
      vscBlueGreen = dark and "#4ec9b0" or "#2b91af",
      vscLightRed = dark and "#d16969" or "#a31515",
      vscLightGreen = dark and "#b5cea8" or "#000000",
    },
    group_overrides = groups,
  })
  vim.opt.background = style
  vim.cmd.colorscheme("vscode")
end

vim.api.nvim_create_user_command("Light", function()
  set_style("light")
end, { desc = "Classic Visual Studio light theme", force = true })
vim.api.nvim_create_user_command("Dark", function()
  set_style("dark")
end, { desc = "Classic Visual Studio dark theme", force = true })

vim.cmd([[cnoreabbrev <expr> light getcmdtype() == ':' && getcmdline() ==# 'light' ? 'Light' : 'light']])
vim.cmd([[cnoreabbrev <expr> dark getcmdtype() == ':' && getcmdline() ==# 'dark' ? 'Dark' : 'dark']])

set_style("dark")
