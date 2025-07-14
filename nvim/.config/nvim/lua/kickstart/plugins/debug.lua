return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
    'nicholasmata/nvim-dap-cs',
    'theHamsta/nvim-dap-virtual-text',
  },
  keys = {
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        'delve',
        'coreclr',
      },
    }

    dapui.setup {}
    require('nvim-dap-virtual-text').setup {}

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Track layout and Neo-tree
    local layout_snapshot = nil
    local neotree_was_open = false

    dap.listeners.before.event_initialized['save_layout'] = function()
      if #vim.api.nvim_list_wins() > 1 then
        layout_snapshot = vim.fn.winrestcmd()
      end
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
        if bufname:match 'neo%-tree' then
          neotree_was_open = true
          vim.cmd 'Neotree close'
          break
        end
      end
    end

    local function restore_debug_layout()
      vim.defer_fn(function()
        if layout_snapshot and layout_snapshot ~= '' then
          pcall(vim.cmd, layout_snapshot)
        end
        layout_snapshot = nil
        if neotree_was_open then
          vim.defer_fn(function()
            local ok, neotree = pcall(require, 'neo-tree.command')
            if ok then
              neotree.execute {
                action = 'show',
                toggle = false,
                focus = false,
              }
            end
            neotree_was_open = false
          end, 100)
        end
      end, 150)
    end

    dap.listeners.after.event_terminated['restore_layout'] = restore_debug_layout
    dap.listeners.after.event_exited['restore_layout'] = restore_debug_layout

    -- Go config
    dap.adapters.go = function(callback, _)
      local port = 38697
      vim.fn.jobstart({ 'dlv', 'dap', '-l', '127.0.0.1:' .. port }, { detach = true })
      vim.defer_fn(function()
        callback { type = 'server', host = '127.0.0.1', port = port }
      end, 100)
    end

    dap.configurations.go = {
      {
        type = 'go',
        name = 'Debug file',
        request = 'launch',
        program = '${file}',
        showLog = true,
        dlvToolPath = vim.fn.exepath 'dlv',
        outputMode = 'remote',
      },
    }

    -- Cross-platform netcoredbg binary resolution
    -- local uname = vim.loop.os_uname()
    -- local is_wsl = uname.release:lower():find 'microsoft' ~= nil or uname.version:lower():find 'wsl' ~= nil
    -- local is_windows = uname.sysname:find 'Windows' ~= nil or is_wsl
    -- local sep = package.config:sub(1, 1)
    -- local exe = is_windows and 'netcoredbg.exe' or 'netcoredbg'

    -- Build the full path
    -- local netcoredbg_path = table.concat({
    --   vim.fn.stdpath 'data',
    --   'mason',
    --   'packages',
    --   'netcoredbg',
    --   'netcoredbg',
    --   exe,
    -- }, sep)

    -- Register dap-cs with the correct netcoredbg path
    require('dap-cs').setup {
      -- netcoredbg = {
      --   path = netcoredbg_path,
      -- },
    }

    require('dap-go').setup {
      delve = {
        detached = vim.fn.has 'win32' == 0,
      },
    }
  end,
}
