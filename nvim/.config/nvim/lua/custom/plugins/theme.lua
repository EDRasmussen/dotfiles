return {
  'rebelot/kanagawa.nvim',
  config = function()
    vim.cmd 'colorscheme kanagawa'

    require('kanagawa').setup {
      compile = false,
      transparent = true,
    }

    vim.cmd 'KanagawaCompile'
  end,
}
