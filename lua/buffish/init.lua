local cmd = vim.cmd
local fn = vim.fn
local api = vim.api
local pretty_print = vim.pretty_print

local M = {
    bufnr = false,
    ns = false,
}

M.open = function()
    if not M.bufnr or not api.nvim_buf_is_valid(M.bufnr) then
        M.bufnr = api.nvim_create_buf(false, true)
    end

    if not M.ns then
        M.ns = api.nvim_create_namespace("buffish-ns")
    end

    local self = M.bufnr;
    local ns = M.ns;

    api.nvim_buf_set_option(self, 'buflisted', false)
    api.nvim_buf_set_option(self, 'bufhidden', 'wipe')
    api.nvim_buf_set_option(self, 'buftype', 'nofile')
    api.nvim_buf_set_option(self, 'swapfile', false)
    api.nvim_buf_set_option(self, 'filetype', 'buffish')

    api.nvim_buf_set_keymap(self, 'n', "q", '', {
        callback = function()
            api.nvim_buf_delete(self, {})
        end,
        nowait = true,
        noremap = true,
        silent = true
    })

    render(self, ns)

    api.nvim_win_set_buf(0, self)
    safely_set_cursor(self, 2)
end

function selected_buffer(handles)
    return handles[api.nvim_win_get_cursor(0)[1]].bufnr
end

function safely_set_cursor(self, loc)
    api.nvim_win_set_cursor(0, { math.min(api.nvim_buf_line_count(self), loc), 0 })
end

function render(self, ns)
    local handles = {}
    local names = {}

    local old_conceallevel = vim.wo.conceallevel
    vim.wo.conceallevel = 1
    local old_concealcursor = vim.wo.concealcursor
    vim.wo.concealcursor = "n"

    local autocmd = vim.api.nvim_create_autocmd
    local buffish_group = vim.api.nvim_create_augroup('buffish-au', {clear = true})

    autocmd("BufUnload", {
        buffer = self,
        callback = function()
            vim.wo.conceallevel = old_conceallevel
            vim.wo.concealcursor = old_concealcursor
        end,
        group = buffish_group
    })

    for _, buffer in ipairs(fn.getbufinfo({buflisted = 1})) do
        local name = buffer.name

        if #name > 0 then
            table.insert(handles, buffer)

            local parts = vim.split(buffer.name, "/")
            local filename = parts[#parts]

            names[filename] = names[filename]==nil and 1 or names[filename] + 1
        else
            pretty_print("no name")
        end
    end

    table.sort(handles, function(a,b)
        if a.lastused == b.lastused then
            return a.bufnr > b.bufnr
        else
            return a.lastused > b.lastused
        end
    end)

    api.nvim_buf_set_option(self, 'modifiable', true)
    api.nvim_buf_set_lines(self, 0, -1, false, {})

    for i, buffer in ipairs(handles) do
        api.nvim_buf_set_lines(self, i-1, i, false, { buffer.name })

        local parts = vim.split(buffer.name, "/")
        local filename = parts[#parts]

        local add_prefix = names[filename] > 1

        if add_prefix then
            api.nvim_buf_set_extmark(self, ns, i-1, 0, {virt_text_win_col=0, virt_text={{parts[#parts-1].."/", "Directory"}}})
        end
        api.nvim_buf_set_extmark(self, ns, i-1, 1,
            {virt_text_win_col=add_prefix and #parts[#parts-1]+1 or 0, virt_text={{filename, "Identifier"}}})
    end

    api.nvim_buf_set_option(self, 'modified', false)
    api.nvim_buf_set_option(self, 'modifiable', false)

    api.nvim_buf_set_keymap(self, 'n', "<CR>", '', {
        callback = function()
            api.nvim_win_set_buf(0, selected_buffer(handles))
        end,
        nowait = true,
        noremap = true,
        silent = true
    })

    api.nvim_buf_set_keymap(self, 'n', "dd", '', {
        callback = function()
            local old_line = api.nvim_win_get_cursor(0)[1]
            api.nvim_buf_delete(selected_buffer(handles), {})
            render(self, ns)
            safely_set_cursor(self, old_line)
        end,
        nowait = true,
        noremap = true,
        silent = true
    })
end

return M
