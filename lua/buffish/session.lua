local handles = require("buffish.handles")

local api = vim.api
local cmd = vim.cmd

local bufnr = false
local prev_bufnr = false
local prev_name = ""

local handle_list = {}

local loadBufferAndKeepAlt = function(buffer_number)
  cmd("keepalt buffer " .. buffer_number)
end

local create_buffer = function()
  bufnr = api.nvim_create_buf(false, true)
  vim.bo[bufnr].filetype = "buffish"

  api.nvim_create_autocmd({"BufDelete", "BufAdd"}, {
    callback = function(details)
        if api.nvim_buf_is_loaded(bufnr) and vim.bo[details.buf].buflisted ==
            true then
          require("buffish.display").rerender()
        end
    end,
    group = api.nvim_create_augroup('buffish-session', {clear = true})
  })

  return bufnr
end

local M
M = {
  get_buffer_handles = function()
    handle_list = handles.get()
    return handle_list
  end,

  get_selected_buffer = function()
    return handle_list[api.nvim_win_get_cursor(0)[1]].bufnr
  end,

  get_bufnr = function()
    if not (bufnr and api.nvim_buf_is_valid(bufnr)) then
      bufnr = create_buffer()
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

  select_buf = function()
    local selected_bufnr = M.get_selected_buffer()
    if prev_bufnr == selected_bufnr then
      M.restore_prev_buf()
    else
      loadBufferAndKeepAlt(selected_bufnr)
      if #prev_name > 0 and api.nvim_buf_is_valid(prev_bufnr) then
        cmd.balt(prev_name)
      end
    end
  end
}

return M
