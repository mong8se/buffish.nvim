local fn = vim.fn
local api = vim.api
local display = require("buffish.display")
local session = require("buffish.session")
local shortcuts = require("buffish.shortcuts")

local current_line_number = function() return api.nvim_win_get_cursor(0)[1] end

local selected_buffer = function()
  return session.buf_index[current_line_number()]
end

local requestRerender = function()
  local old_line = current_line_number()
  vim.schedule(function()
    display.render()
    display.safely_set_cursor(old_line)
  end)
end

local M = {
  quit = function() session.restore_prev_buf() end,

  delete = function() api.nvim_buf_delete(selected_buffer(), {}) end,

  assign_shortcut = function()
    shortcuts.set(selected_buffer())
    requestRerender()
  end,

  remove_shortcut = function()
    shortcuts.remove(selected_buffer())
    requestRerender()
  end,

  follow_shortcut = function(key)
    shortcuts.follow(key)
  end,

  select = function() api.nvim_win_set_buf(0, selected_buffer()) end,

  rerender = function(details)
    -- Meant to be called by BufDelete and BufAdd events
    -- If the buffer that triggered the event is the buffish
    -- buffer itself or an unlisted buffer, we don't need
    -- to rerender
    if details.buf == session.get_bufnr() or
        api.nvim_buf_get_option(details.buf, 'buflisted') == false then
      return
    end

    requestRerender()
  end,

  split = function()
    local which = "split"

    if fn.winwidth(0) > fn.winheight(0) * 2 then which = "vsplit" end

    local line = api.nvim_win_get_cursor(0)[1]
    vim.cmd(string.format("%s %s", which,
                          api.nvim_buf_get_lines(0, line - 1, line, true)[1]))
  end
}

return M
