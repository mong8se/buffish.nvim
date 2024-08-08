--- Buffish's own buffer
local api = vim.api
local cmd = vim.cmd

local bufnr = false
local prev_bufnr = false
local prev_name = ""

local loadBufferAndKeepAlt = function(buffer_number)
  cmd("keepalt buffer " .. buffer_number)
end

local M

M = {
  buf_index = {},

  get_bufnr = function()
    if not (bufnr and api.nvim_buf_is_valid(bufnr)) then
      bufnr = api.nvim_create_buf(false, true)
    end

    return bufnr
  end,

  open_session_buffer = function()
    prev_bufnr = api.nvim_win_get_buf(0)
    prev_name = api.nvim_buf_get_name(0)
    loadBufferAndKeepAlt(bufnr)
  end,

  restore_prev_buf = function()
    if api.nvim_buf_is_valid(prev_bufnr) then
      loadBufferAndKeepAlt(prev_bufnr)
    else
      api.nvim_buf_delete(0, {})
    end
  end,

  select_buf = function(selected_bufnr)
    if prev_bufnr == selected_bufnr then
      M.restore_prev_buf()
    else
      loadBufferAndKeepAlt(selected_bufnr)
      if api.nvim_buf_is_valid(prev_bufnr) then cmd.balt(prev_name) end
    end
  end
}

return M
