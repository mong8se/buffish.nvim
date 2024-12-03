local session = require("buffish.session")
local shortcuts = require("buffish.shortcuts")
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

local get_selected_buffer = function()
  return vim.b.buffish_index[api.nvim_win_get_cursor(0)[1]]
end

return {
  quit = function() session.restore_prev_buf() end,

  delete = function() api.nvim_buf_delete(get_selected_buffer(), {}) end,

  assign_shortcut = function()
    if shortcuts.set(get_selected_buffer()) then session.rerender() end
  end,

  remove_shortcut = function()
    shortcuts.remove(get_selected_buffer())
    session.rerender()
  end,

  select = function() session.select_buf(get_selected_buffer()) end,

  split = function()
    cmd({
      cmd = (fn.winwidth(0) > fn.winheight(0) * 2) and "vsplit" or "split",
      args = {api.nvim_get_current_line()}
    })
  end,

  goto_parent_directory = function()
    cmd.edit(vim.fs.dirname(api.nvim_get_current_line()))
  end
}
