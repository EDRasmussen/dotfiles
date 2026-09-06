local function on_attach(bufnr)
  local api = require("nvim-tree.api")
  local function map(key, action, desc)
    vim.keymap.set("n", key, action, { buffer = bufnr, silent = true, nowait = true, desc = desc })
  end

  map("<CR>", api.node.open.edit, "Open file / expand directory")
  map("-", api.tree.change_root_to_parent, "Up a directory")
  map("<BS>", api.node.navigate.parent_close, "Collapse directory")
  map("%", api.fs.create, "Create file (trailing / creates directory)")
  map("d", function()
    local node = api.tree.get_node_under_cursor()
    if not node then
      return
    end
    local directory = node.type == "directory" and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
    vim.ui.input({ prompt = "Create directory: ", default = directory .. "/", completion = "dir" }, function(path)
      if not path or path == "" or path == directory .. "/" then
        return
      end
      local ok, result = pcall(vim.fn.mkdir, path, "p")
      if not ok or result == 0 then
        vim.notify("Could not create directory: " .. path, vim.log.levels.WARN)
        return
      end
      api.tree.reload()
    end)
  end, "Create directory")
  map("D", api.fs.remove, "Delete (confirm)")
  map("R", api.fs.rename, "Rename / move")
  map("o", api.node.open.horizontal, "Open in horizontal split")
  map("v", api.node.open.vertical, "Open in vertical split")
  map("t", api.node.open.tab, "Open in new tab")
  map("p", api.node.open.preview, "Preview")
  map("x", api.node.run.system, "Open with system application")
  map("gh", api.filter.dotfiles.toggle, "Toggle hidden files")
  map("I", api.filter.git.ignored.toggle, "Toggle gitignored files")
  map("<C-l>", api.tree.reload, "Refresh")
  map("c", api.fs.copy.node, "Copy")
  map("X", api.fs.cut, "Cut")
  map("P", api.fs.paste, "Paste")
  map("[c", api.node.navigate.git.prev, "Previous Git change")
  map("]c", api.node.navigate.git.next, "Next Git change")
  map("q", api.tree.close, "Close tree")
  map("g?", api.tree.toggle_help, "Tree keybindings")
end

require("nvim-tree").setup({
  on_attach = on_attach,
  disable_netrw = true,
  hijack_netrw = true,
  hijack_directories = { enable = false },
  view = { width = 32, side = "left", signcolumn = "no" },
  renderer = {
    group_empty = true,
    highlight_git = "name",
    indent_markers = { enable = true },
    icons = { git_placement = "after" },
  },
  git = { enable = true },
  filters = { dotfiles = false, git_ignored = true },
  filesystem_watchers = { enable = true },
  update_focused_file = { enable = true },
  actions = { open_file = { quit_on_open = false } },
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("FileTreeStartup", { clear = true }),
  once = true,
  nested = true,
  callback = function()
    if #vim.api.nvim_list_uis() == 0 or vim.tbl_contains(vim.v.argv, "-") then
      return
    end
    local api = require("nvim-tree.api")
    local window = vim.api.nvim_get_current_win()
    local path = vim.api.nvim_buf_get_name(0)
    local is_directory = path ~= "" and vim.fn.isdirectory(path) == 1
    if is_directory then
      local directory_buffer = vim.api.nvim_get_current_buf()
      vim.cmd.tcd(vim.fn.fnameescape(path))
      vim.cmd.enew()
      vim.api.nvim_buf_delete(directory_buffer, { force = false })
    end
    api.tree.open({ path = is_directory and path or nil })
    if not is_directory then
      api.tree.find_file({ open = true, focus = false })
      vim.api.nvim_set_current_win(window)
    end
  end,
})
