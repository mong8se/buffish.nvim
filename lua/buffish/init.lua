local session = require("buffish.session")
local display = require("buffish.display")

local api = vim.api

local M = {
  open = function()
    local buffnr = session.get_bufnr()
    api.nvim_buf_set_option(buffnr, 'filetype', 'buffish')

    display.render()

    session.save_current_buf()

    api.nvim_win_set_buf(0, buffnr)
    display.safely_set_cursor(2)
  end
}

return M
