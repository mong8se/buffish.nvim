local fn = vim.fn
local api = vim.api
local display = require("buffish.display")
local session = require("buffish.session")

local current_line_number = function()
    return api.nvim_win_get_cursor(0)[1]
end

local selected_buffer = function()
    return session.buf_index[current_line_number()]
end

local M = {
    quit = function()
        -- TODO: Is this the best way to close and return to previous buffer?
        -- api.nvim_buf_delete(0, {})
        api.nvim_win_close(0, true)
    end,

    delete = function()
        local old_line = current_line_number()
        api.nvim_buf_delete(selected_buffer(), {})
        vim.schedule(function()
            display.safely_set_cursor(old_line)
        end)
    end,

    select = function()
        api.nvim_win_set_buf(0, selected_buffer())
    end,

    rerender = function(details)
        if details.buf == session.get_bufnr() or
            api.nvim_buf_get_option(details.buf, 'buflisted') == false then
            return
        end
        vim.schedule(display.render)
    end,

    split = function()
        local which = "split"

        if fn.winwidth(0) > fn.winheight(0) * 2 then which = "vsplit" end

        local line = api.nvim_win_get_cursor(0)[1]
        cmd(string.format("%s %s", which, api.nvim_buf_get_lines(0, line-1, line, true)[1] ))
    end
}

return M
