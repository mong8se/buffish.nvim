local display = require("buffish.display")

local api = vim.api
local cmd = vim.cmd

local M = {}
local bufnr = false
local prev_bufnr = false
local prev_name = ""

local load_buffer_and_keep_alt = function(buffer_number)
  cmd("keepalt buffer " .. buffer_number)
end

local get_session_buffer = function()
  if not (bufnr and api.nvim_buf_is_valid(bufnr)) then
    bufnr = api.nvim_create_buf(false, true)
    vim.bo[bufnr].filetype = "buffish"
    display.render(bufnr)

    local group = api.nvim_create_augroup('buffish-session', {clear = true})

    api.nvim_create_autocmd({"BufDelete", "BufEnter"}, {
      callback = function(details)
        if api.nvim_buf_is_loaded(bufnr) and vim.bo[details.buf].buflisted ==
            true then M.rerender() end
      end,
      group = group
    })

    api.nvim_create_autocmd("BufWipeout", {
      buffer = bufnr,
      callback = function() api.nvim_del_augroup_by_id(group) end,
      group = group
    })
  end

  return bufnr
end

local safely_set_cursor = function(row)
  local win = vim.fn.getwininfo(vim.fn.win_getid())[1]

  if win.bufnr == get_session_buffer() then
    api.nvim_win_set_cursor(win.winid, {
      math.min(api.nvim_buf_line_count(win.bufnr), row), 0
    })
  end
end

M.open_session_buffer = function()
  prev_bufnr = api.nvim_win_get_buf(0)
  prev_name = api.nvim_buf_get_name(0)
  load_buffer_and_keep_alt(get_session_buffer())
  safely_set_cursor(2)
end

M.restore_prev_buf = function()
  if api.nvim_buf_is_valid(prev_bufnr) then
    load_buffer_and_keep_alt(prev_bufnr)
  else
    api.nvim_buf_delete(0, {})
  end
end

M.select_buf = function(selected_bufnr)
  if prev_bufnr == selected_bufnr then
    M.restore_prev_buf()
  else
    load_buffer_and_keep_alt(selected_bufnr)
    if #prev_name > 0 and api.nvim_buf_is_valid(prev_bufnr) then
      cmd.balt(prev_name)
    end
  end
end

M.rerender = function()
  local old_line = api.nvim_win_get_cursor(0)[1]
  vim.schedule(function()
    display.render(get_session_buffer())
    safely_set_cursor(old_line)
  end)
end

return M
