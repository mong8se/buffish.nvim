local display = require("buffish.display")
local session = require("buffish.session")
local shortcuts = require("buffish.shortcuts")
local fn = vim.fn
local api = vim.api


local M = {
  quit = function() session.restore_prev_buf() end,

  delete = function() api.nvim_buf_delete(session.get_selected_buffer(), {}) end,

  assign_shortcut = function()
    if shortcuts.set(session.get_selected_buffer()) then display.rerender() end
  end,

  remove_shortcut = function()
    shortcuts.remove(session.get_selected_buffer())
    display.rerender()
  end,

  select = session.select_buf,

  split = function()
    local which = "split"

    if fn.winwidth(0) > fn.winheight(0) * 2 then which = "vsplit" end

    local line = api.nvim_win_get_cursor(0)[1]
    vim.cmd(string.format("%s %s", which,
                          api.nvim_buf_get_lines(0, line - 1, line, true)[1]))
  end
}

return M
