local session = require("buffish.session")
local display = require("buffish.display")

local api = vim.api

local M = {
  open = function()
    local buffnr = session.get_bufnr()

    api.nvim_buf_set_option(buffnr, 'filetype', 'buffish')

    display.render()

    session.open_session_buffer()

    display.safely_set_cursor(2)
  end
}

return M
