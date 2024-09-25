local fn = vim.fn
local b = vim.b
local api = vim.api

local shortcuts = {}

return {
  set = function(bufnr)
    local key = fn.getcharstr()

    local old_bufnr = shortcuts[key]
    local old_key = b[bufnr].buffish_shortcut

    if not old_bufnr or old_bufnr ~= bufnr then
      shortcuts[key] = bufnr
      b[bufnr].buffish_shortcut = key

      if old_bufnr then b[old_bufnr].buffish_shortcut = nil end
      if old_key then shortcuts[old_key] = nil end

      return true
    end
  end,

  get = function(bufnr) return b[bufnr].buffish_shortcut end,

  follow = function(key)
    if not key then key = fn.getcharstr() end

    local bufnr = shortcuts[key]
    if bufnr and api.nvim_buf_is_valid(bufnr) and
        api.nvim_buf_get_option(bufnr, 'buflisted') then
      api.nvim_win_set_buf(0, bufnr)
    else
      vim.notify(string.format("No buffer found for '%s'", key),
                 vim.log.levels.WARN)
    end
  end,

  remove = function(bufnr)
    local key = b[bufnr].buffish_shortcut

    shortcuts[key] = nil
    b[bufnr].buffish_shortcut = nil
  end
}
