local api = vim.api

local bufnr = false
local prev_bufnr = false

local M = {
  buf_index = {},

  get_bufnr = function()
    if not (bufnr and api.nvim_buf_is_valid(bufnr)) then
      bufnr = api.nvim_create_buf(false, true)
    end

    return bufnr
  end,

  save_current_buf = function() prev_bufnr = api.nvim_win_get_buf(0) end,

  restore_prev_buf = function()
    if api.nvim_buf_is_valid(prev_bufnr) then
      api.nvim_win_set_buf(0, prev_bufnr)
    else
      api.nvim_buf_delete(0, {})
    end
  end
}

return M
