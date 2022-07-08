local api = vim.api

local bufnr = false

local session = {
  getBufnr = function()
    if not (bufnr and api.nvim_buf_is_valid(bufnr)) then
      bufnr = api.nvim_create_buf(false, true)
    end

    return bufnr
  end
}

return session
