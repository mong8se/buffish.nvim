local fn = vim.fn
local api = vim.api
local session = require("buffish.session")

local ns = api.nvim_create_namespace("buffish-ns")

local extract_filename = function(name, depth)
    local parts = vim.split(name, "/", { plain = true, trimempty = true })

    local filename = string.format(string.rep("%s", depth + 1, "/"),
        unpack(parts, #parts - depth))

    return filename
end

local safely_insert = function(list, entry)
    list = list or {}
    table.insert(list, entry)
    return list
end

local disambiguate
disambiguate = function(handles, names, depth)
    local matches_found = false
    local results = {}

    for name, bufl in pairs(names) do
        if #bufl < 2 then
            results[name] = names[name]
        else
            matches_found = true
            for _, bufi in ipairs(bufl) do
                local filename = extract_filename(handles[bufi].name, depth)
                results[filename] = safely_insert(results[filename], bufi)
            end
        end
    end

    if matches_found then
        return disambiguate(handles, results, depth + 1)
    else
        return results
    end
end

local get_buffer_handles = function()
    local handles = {}
    local names = {}

    for i, buffer in ipairs(fn.getbufinfo({buflisted = 1})) do
        if #buffer.name > 0 then
            table.insert(handles, buffer)
            filename = extract_filename(buffer.name, 0)
            names[filename] = safely_insert(names[filename], i)
        end
    end

    names = disambiguate(handles, names, 1)

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

local current_line_number = function()
    return api.nvim_win_get_cursor(0)[1]
end

local lib = {
    render = function()
        local handles = get_buffer_handles()
        local bufnr = session.get_bufnr()
        session.buf_index = {}

        api.nvim_buf_set_option(bufnr, 'modifiable', true)
        api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

        for i, buffer in ipairs(handles) do
            -- if not api.nvim_buf_is_valid(buffer.bufnr) then break end
            session.buf_index[i] = buffer.bufnr

            api.nvim_buf_set_lines(bufnr, i - 1, i, false, {buffer.name})

            local filename = vim.fn.fnamemodify(buffer.display_name, ":t")

            api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
                sign_text = string.format("%2i", buffer.bufnr),
                end_col = #buffer.name - #buffer.display_name,
                hl_group = "Normal",
                conceal = " "
            })

            api.nvim_buf_set_extmark(bufnr, ns, i - 1, #buffer.name - #buffer.display_name, {
                hl_group = "Directory",
                end_col = #buffer.name - #filename
            })

            api.nvim_buf_set_extmark(bufnr, ns, i - 1, #buffer.name - #filename, {
                hl_group = "Identifier",
                end_col = #buffer.name
            })
        end

        api.nvim_buf_set_option(bufnr, 'modified', false)
        api.nvim_buf_set_option(bufnr, 'modifiable', false)
    end,

    safely_set_cursor = function(loc)
        api.nvim_win_set_cursor(0, {math.min(api.nvim_buf_line_count(session.get_bufnr()), loc), 0})
    end,

    selected_buffer = function()
        return session.buf_index[current_line_number()]
    end
}

return lib
