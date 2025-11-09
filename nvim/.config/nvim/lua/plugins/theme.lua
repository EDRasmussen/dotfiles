-- return {
--   'rebelot/kanagawa.nvim',
--   config = function()
--     vim.cmd 'colorscheme kanagawa'
--
--     require('kanagawa').setup {
--       compile = false,
--       transparent = true,
--     }
--
--     vim.cmd 'KanagawaCompile'
--   end,
-- }
return {
  'Kaikacy/Lemons.nvim',
  version = '*', -- for stable release
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme 'lemons'
    -- or
    -- require("lemons").load()
    -- there is no difference between these two
  end,
}
