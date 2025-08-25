return {
  'iofq/dart.nvim',
  opts = {
    marklist = { 'a', 's', 'd', 'f', 'q', 'w', 'e', 'r' },
    buflist = {},

    tabline = {
      always_show = false,
    },

    mappings = {
      mark = ';;', -- Mark current buffer
      jump = ';', -- Jump to buffer marked by next character i.e `;a`
      pick = ';p', -- Open Dart.pick
      next = '<S-l>', -- Cycle right through the tabline
      prev = '<S-h>', -- Cycle left through the tabline
    },
  },
}
