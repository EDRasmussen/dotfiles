-- FTerm (floating terminal)
return {
  'numToStr/FTerm.nvim',
  config = function()
    local fterm = require 'FTerm'

    fterm.setup {
      border = 'rounded',
      dimensions = {
        height = 0.9,
        width = 0.9,
        x = 0.5,
        y = 0.5,
      },
      blend = 0,
    }
    vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#89b4fa', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
    -- Toggle FTerm with <A-t> (Alt+t)
    vim.keymap.set({ 'n', 't' }, '<A-t>', fterm.toggle, { desc = 'Toggle FTerm' })
  end,
}
