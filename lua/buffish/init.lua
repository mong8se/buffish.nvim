local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

local session = require("buffish.session")
local lib = require("buffish.lib")

local M = {
}

M.open = function()
    local buffnr = session.get_bufnr()
    api.nvim_buf_set_option(buffnr, 'filetype', 'buffish')

    lib.render()

    api.nvim_win_set_buf(0, buffnr)
    lib.safely_set_cursor(2)
end

M.actions = {
    quit = function()
        -- TODO: Is this the best way to close and return to previous buffer?
        api.nvim_buf_delete(0, {})
    end,

    delete = function()
        local old_line = current_line_number()
        api.nvim_buf_delete(lib.selected_buffer(), {})
        vim.schedule(function()
            lib.safely_set_cursor(old_line)
        end)
    end,

    select = function()
        api.nvim_win_set_buf(0, lib.selected_buffer())
    end,

    rerender = function(details)
        if details.buf == session.get_bufnr() or
            api.nvim_buf_get_option(details.buf, 'buflisted') == false then
            return
        end
        vim.schedule(lib.render)
    end,

    split = function()
        local which = "split"

        if fn.winwidth(0) > fn.winheight(0) * 2 then which = "vsplit" end

        local line = api.nvim_win_get_cursor(0)[1]
        cmd(string.format("%s %s", which, api.nvim_buf_get_lines(0, line-1, line, true)[1] ))
    end
}

return M
