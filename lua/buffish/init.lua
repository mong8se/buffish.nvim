local cmd = vim.cmd
local fn = vim.fn
local api = vim.api
local pretty_print = vim.pretty_print

local M = {
    bufnr = false,
    ns = api.nvim_create_namespace("buffish-ns"),
    augroup = vim.api.nvim_create_augroup('buffish-au',
        {clear = true})
}

M.open = function()
    if not (M.bufnr and api.nvim_buf_is_valid(M.bufnr)) then
        M.bufnr = api.nvim_create_buf(false, true)
    end

    local handles = get_buffer_handles()

    api.nvim_buf_set_option(M.bufnr, 'buflisted', false)
    api.nvim_buf_set_option(M.bufnr, 'bufhidden', 'wipe')
    api.nvim_buf_set_option(M.bufnr, 'buftype', 'nofile')
    api.nvim_buf_set_option(M.bufnr, 'swapfile', false)
    api.nvim_buf_set_option(M.bufnr, 'filetype', 'buffish')

    save_window_settings()

    set_mappings(handles)

    render(handles)
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
        else
            -- pretty_print("no name")
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

function render(handles)
    api.nvim_buf_set_option(M.bufnr, 'modifiable', true)
    api.nvim_buf_set_lines(M.bufnr, 0, -1, false, {})

    for i, buffer in ipairs(handles) do
        api.nvim_buf_set_lines(M.bufnr, i - 1, i, false, {buffer.name})

        local parts = vim.split(buffer.display_name, "/")
        local distance = 0

        api.nvim_buf_set_extmark(M.bufnr, M.ns, i - 1, 0, {
            sign_text = string.format("% i", buffer.bufnr)
        })

        for j = 1, #parts do
            -- api.nvim_buf_set_extmark(M.bufnr, M.ns, i - 1, 0, {
            api.nvim_buf_set_extmark(M.bufnr, M.ns, i - 1, distance, {
                virt_text_hide = true,
                -- virt_text_win_col = distance,
                virt_text = {
                    j == #parts and {parts[j], "Identifier"} or
                        {parts[j] .. "/", "Directory"}
                }
            })
            distance = distance + 1 + #parts[j]
        end
    end

    api.nvim_buf_set_option(M.bufnr, 'modified', false)
    api.nvim_buf_set_option(M.bufnr, 'modifiable', false)
end

function selected_buffer(handles)
    return handles[api.nvim_win_get_cursor(0)[1]].bufnr
end

function safely_set_cursor(loc)
    api.nvim_win_set_cursor(0, {math.min(api.nvim_buf_line_count(M.bufnr), loc), 0})
end

function find_matches(list, name, pass_number, bufi)
    local parts = vim.split(name, "/")

    local filename = string.format(string.rep("%s/", pass_number) .. "%s",
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

function save_window_settings()
    vim.w.old_conceallevel = vim.wo.conceallevel
    vim.wo.conceallevel = 1
    vim.w.old_concealcursor = vim.wo.concealcursor
    vim.wo.concealcursor = "n"

    api.nvim_create_autocmd("BufUnload", {
        buffer = M.bufnr,
        callback = function()
            vim.wo.conceallevel = vim.w.old_conceallevel
            vim.wo.concealcursor = vim.w.old_concealcursor
        end,
        group = M.augroup
    })
end

function set_mappings(handles)
    api.nvim_buf_set_keymap(M.bufnr, 'n', "q", '', {
        -- TODO: Is this the best way to close and return to previous buffer?
        callback = function() api.nvim_buf_delete(M.bufnr, {}) end,
        nowait = true,
        noremap = true,
        silent = true
    })

    api.nvim_buf_set_keymap(M.bufnr, 'n', "<CR>", '', {
        callback = function()
            api.nvim_win_set_buf(0, selected_buffer(handles))
        end,
        nowait = true,
        noremap = true,
        silent = true
    })

    api.nvim_buf_set_keymap(M.bufnr, 'n', "dd", '', {
        callback = function()
            local old_line = api.nvim_win_get_cursor(0)[1]
            api.nvim_buf_delete(selected_buffer(handles), {})
            render(M.bufnr)
            safely_set_cursor(M.bufnr, old_line)
        end,
        nowait = true,
        noremap = true,
        silent = true
    })
end

return M
