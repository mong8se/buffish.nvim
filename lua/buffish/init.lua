local session = require("buffish.session")
local display = require("buffish.display")

local M = {
  open = function()
    display.render()

    session.open_session_buffer()

    display.safely_set_cursor(2)
  end
}

return M
