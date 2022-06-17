local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

local M = {
    bufnr = false,
    ns = api.nvim_create_namespace("buffish-ns"),
}

M.open = function()
    if not (M.bufnr and api.nvim_buf_is_valid(M.bufnr)) then
        M.bufnr = api.nvim_create_buf(false, true)
    end

    api.nvim_buf_set_option(M.bufnr, 'filetype', 'buffish')

    render()

    api.nvim_win_set_buf(0, M.bufnr)
    safely_set_cursor(2)
end

function get_buffer_handles()
    local handles = {}
    local names = {}

    for i, buffer in ipairs(fn.getbufinfo({buflisted = 1})) do
        if #buffer.name > 0 then
            table.insert(handles, buffer)
            find_matches(names, buffer.name, 0, i)
        end
    end

    names = disamb(handles, names, 1)

    for name, bufl in pairs(names) do
        for _, bufi in ipairs(bufl) do handles[bufi].display_name = name end
    end

    table.sort(handles, function(a, b)
        if a.lastused == b.lastused then
            return a.bufnr > b.bufnr
        else
            return a.lastused > b.lastused
        end
    end)

    return handles
end

function render()
    local handles = get_buffer_handles()
    local line_to_bufnr = {}

    api.nvim_buf_set_option(M.bufnr, 'modifiable', true)
    api.nvim_buf_set_lines(M.bufnr, 0, -1, false, {})

    for i, buffer in ipairs(handles) do
        -- if not api.nvim_buf_is_valid(buffer.bufnr) then break end
        line_to_bufnr[i] = buffer.bufnr

        api.nvim_buf_set_lines(M.bufnr, i - 1, i, false, {buffer.name})

        local filename = vim.fn.fnamemodify(buffer.display_name, ":t")

        api.nvim_buf_set_extmark(M.bufnr, M.ns, i - 1, 0, {
            sign_text = string.format("%2i", buffer.bufnr),
            end_col = #buffer.name - #buffer.display_name,
            hl_group = "Normal",
            conceal = " "
        })

        api.nvim_buf_set_extmark(M.bufnr, M.ns, i - 1, #buffer.name - #buffer.display_name, {
            hl_group = "Directory",
            end_col = #buffer.name - #filename
        })

        api.nvim_buf_set_extmark(M.bufnr, M.ns, i - 1, #buffer.name - #filename, {
            hl_group = "Identifier",
            end_col = #buffer.name
        })
    end
    api.nvim_buf_set_var(M.bufnr, 'line_to_bufnr', line_to_bufnr)
    api.nvim_buf_set_option(M.bufnr, 'modified', false)
    api.nvim_buf_set_option(M.bufnr, 'modifiable', false)
end

function current_line_number()
    return api.nvim_win_get_cursor(0)[1]
end

function selected_buffer()
    return vim.b[M.bufnr].line_to_bufnr[current_line_number()]
end

function safely_set_cursor(loc)
    api.nvim_win_set_cursor(0, {math.min(api.nvim_buf_line_count(M.bufnr), loc), 0})
end

function find_matches(list, name, pass_number, bufi)
    local parts = vim.split(name, "/")

    local filename = string.format(string.rep("%s", pass_number + 1, "/"),
        unpack(parts, #parts - pass_number))

    if list[filename] == nil then list[filename] = {} end

    table.insert(list[filename], bufi)
end

function disamb(handles, names, pass_number)
    local matches_found = false
    local results = {}

    for name, bufl in pairs(names) do
        if #bufl < 2 then
            results[name] = names[name]
        else
            matches_found = true
            for _, bufi in ipairs(bufl) do
                find_matches(results, handles[bufi].name, pass_number, bufi)
            end
        end
    end

    if matches_found then
        return disamb(handles, results, pass_number + 1)
    else
        return results
    end
end

M.actions = {
    quit = function()
        -- TODO: Is this the best way to close and return to previous buffer?
        api.nvim_buf_delete(0, {})
    end,
    delete = function()
        local old_line = current_line_number()
        api.nvim_buf_delete(selected_buffer(), {})
        vim.schedule(function()
            safely_set_cursor(old_line)
        end)
    end,
    select = function()
        api.nvim_win_set_buf(0, selected_buffer())
    end,
    rerender = function(details)
        if details.buf == M.bufnr or
            api.nvim_buf_get_option(details.buf, 'buflisted') == false then
            return
        end
        vim.schedule(render)
    end
}

return M
