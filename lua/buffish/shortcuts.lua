local fn = vim.fn
local api = vim.api
local key_to_bufnr = {}
local bufnr_to_key = {}

local M = {
  set = function(bufnr)
    local key = fn.getcharstr()
    local old_bufnr = key_to_bufnr[key]

    key_to_bufnr[key] = bufnr
    bufnr_to_key[bufnr] = key

    if old_bufnr then bufnr_to_key[old_bufnr] = nil end
  end,

  get = function(bufnr) return bufnr_to_key[bufnr] end,

  follow = function(key)
    if not key then key = fn.getcharstr() end

    local bufnr = key_to_bufnr[key]
    if bufnr and api.nvim_buf_is_valid(bufnr) and
        api.nvim_buf_get_option(bufnr, 'buflisted') then
      api.nvim_win_set_buf(0, bufnr)
    else
      vim.notify(string.format("No buffer found for '%s'", key),
                 vim.log.levels.WARN)
    end
  end,

  remove = function(bufnr)
    local key = bufnr_to_key[bufnr]

    key_to_bufnr[key] = nil
    bufnr_to_key[bufnr] = nil
  end
}

return M
