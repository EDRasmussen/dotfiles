-- Buffer line (browser tabs, but for files!)
return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require('bufferline').setup {}
    vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>')
    vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>')
    vim.keymap.set('n', '<M-w>', function()
      local bufnr = vim.api.nvim_get_current_buf()
      local buffers = vim.fn.getbufinfo { buflisted = 1 }
      if #buffers > 1 then
        vim.cmd 'bnext' -- switch to next buffer
        vim.cmd('bd ' .. bufnr) -- delete the old one
      else
        vim.cmd 'bd' -- just delete if it's the only one
      end
    end, { noremap = true, silent = true, desc = 'Close buffer and move to next' })
  end,
}
