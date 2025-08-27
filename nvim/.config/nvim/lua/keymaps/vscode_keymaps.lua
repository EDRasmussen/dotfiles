local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
local vscode = function(action)
  return "<cmd>lua require('vscode').action('" .. action .. "')<CR>"
end

-- Set <Space> as leader (safe to repeat for VSCode if needed)
keymap('n', '<Space>', '', opts)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Clipboard ]]
keymap({ 'n', 'v' }, '<leader>y', '"+y', { desc = '[Y]ank to system clipboard' })
keymap({ 'n', 'v' }, '<leader>p', '"+p', { desc = '[P]aste from system clipboard' })

-- [[ Indentation ]]
keymap('v', '<', '<gv', { desc = 'Indent left and reselect' })
keymap('v', '>', '>gv', { desc = 'Indent right and reselect' })

-- [[ Move lines up/down ]]
keymap('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selected lines down' })
keymap('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selected lines up' })
keymap('x', 'J', ":move '>+1<CR>gv-gv", { desc = 'Move block down' })
keymap('x', 'K', ":move '<-2<CR>gv-gv", { desc = 'Move block up' })

-- [[ Paste without yanking ]]
keymap('v', 'p', '"_dP', { desc = 'Paste without yanking' })

-- [[ Clear highlight ]]
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- [[ VSCode Actions ]]
keymap('n', '<leader>ca', vscode 'editor.action.quickFix', { desc = 'Quick fix (VSCode)' })
keymap('n', '<C-d>r', vscode 'editor.action.rename', { desc = 'Rename symbol (VSCode)' })
keymap('n', '<leader>f', vscode 'editor.action.formatDocument', { desc = 'Format document (VSCode)' })
keymap('n', '<M>t', vscode 'workbench.action.terminal.toggleTerminal', { desc = 'Toggle terminal (VSCode)' })
keymap('n', '<leader>b', vscode 'editor.debug.action.toggleBreakpoint', { desc = 'Toggle breakpoint (VSCode)' })
keymap('n', '<leader>xx', vscode 'workbench.actions.view.problems', { desc = 'Open problems pane (VSCode)' })
keymap('n', '<leader>gd', vscode 'editor.action.revealDefinition', { desc = '[G]oto [D]efinition (VSCode)' })
keymap('n', '<leader>gr', vscode 'editor.action.referenceSearch.trigger', { desc = '[G]oto [R]eferences (VSCode)' })
keymap('n', '<leader>gi', vscode 'editor.action.goToImplementation', { desc = '[G]oto [I]mplementation (VSCode)' })

-- [[ Leader Shortcuts ]]
keymap('n', '<leader>ff', vscode 'workbench.action.quickOpen', { desc = '[F]ind [F]ile (VSCode)' })
keymap('n', '<leader>fg', vscode 'search.action.openNewEditor', { desc = '[F]ind [G]rep (Search Editor)' })
keymap('n', '<leader>cp', vscode 'workbench.action.showCommands', { desc = '[C]ommand [P]alette' })
keymap('n', '<leader>cn', vscode 'notifications.clearAll', { desc = '[C]lear [N]otifications' })
keymap('n', '<leader>pr', vscode 'code-runner.run', { desc = '[P]lay [R]un file (code-runner)' })

-- [[ Window Navigation ]]
keymap('n', '<C-w>h', vscode 'workbench.action.navigateLeft', { desc = 'Focus left split (VSCode)' })
keymap('n', '<C-w>l', vscode 'workbench.action.navigateRight', { desc = 'Focus right split (VSCode)' })
keymap('n', '<C-w>j', vscode 'workbench.action.navigateDown', { desc = 'Focus down split (VSCode)' })
keymap('n', '<C-w>k', vscode 'workbench.action.navigateUp', { desc = 'Focus up split (VSCode)' })

-- [[ Splits ]]
keymap('n', '<C-w>v', vscode 'workbench.action.splitEditorRight', { desc = 'Split editor vertically' })
keymap('n', '<C-w>s', vscode 'workbench.action.splitEditorDown', { desc = 'Split editor horizontally' })

-- [[ Tab/File Navigation ]]
keymap('n', '<Tab>', vscode 'workbench.action.nextEditor', { desc = 'Next buffer/file tab' })
keymap('n', '<S-Tab>', vscode 'workbench.action.previousEditor', { desc = 'Previous buffer/file tab' })
keymap('n', '<C-w>q', vscode 'workbench.action.closeActiveEditor', { desc = 'Close active buffer/tab' })

-- [[ Comment Toggle ]]
keymap('n', 'gc', vscode 'editor.action.commentLine', { desc = 'Toggle comment (line)' })
keymap('v', 'gc', vscode 'editor.action.commentLine', { desc = 'Toggle comment (visual)' })

-- [[ Diagnostics ]]
keymap('n', '[d', vscode 'editor.action.marker.prev', { desc = 'Previous diagnostic' })
keymap('n', ']d', vscode 'editor.action.marker.next', { desc = 'Next diagnostic' })

-- [[ Find / Files ]]
keymap('n', '<leader>fb', vscode 'workbench.action.showAllEditors', { desc = '[F]ind [B]uffers' })
keymap('n', '<leader>fr', vscode 'workbench.action.openRecent', { desc = '[F]ind [R]ecent files' })
