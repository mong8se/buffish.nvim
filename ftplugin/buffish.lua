local api = vim.api
local w = vim.w
local wo = vim.wo

local actions = require("buffish.actions")

api.nvim_buf_set_option(0, 'buflisted', false)
api.nvim_buf_set_option(0, 'bufhidden', 'delete')
api.nvim_buf_set_option(0, 'buftype', 'nofile')
api.nvim_buf_set_option(0, 'swapfile', false)

local augroup = vim.api.nvim_create_augroup('buffish-au', {clear = true})

api.nvim_create_autocmd("BufWinEnter", {
  buffer = 0,
  callback = function()
    w.buffish_saved_conceallevel = wo.conceallevel
    wo.conceallevel = 1

    w.buffish_saved_concealcursor = wo.concealcursor
    wo.concealcursor = "n"

    w.buffish_saved_wrap = wo.wrap
    wo.wrap = false
  end,
  group = augroup
})

api.nvim_create_autocmd("BufWinLeave", {
  buffer = 0,
  callback = function()
    wo.conceallevel = w.buffish_saved_conceallevel
    w.buffish_saved_conceallevel = nil

    wo.concealcursor = w.buffish_saved_concealcursor
    w.buffish_saved_concealcursor = nil

    wo.wrap = w.buffish_saved_wrap
    w.buffish_saved_wrap = nil

    api.nvim_clear_autocmds({ group = augroup })
  end,
  group = augroup
})

api.nvim_create_autocmd({"BufDelete", "BufAdd"}, {
  callback = function(details) actions.rerender(details) end,
  group = augroup
})

api.nvim_buf_set_keymap(0, 'n', "q", '', {
  callback = actions.quit,
  nowait = true,
  noremap = true,
  silent = true
})

api.nvim_buf_set_keymap(0, 'n', "<CR>", '', {
  callback = actions.select,
  nowait = true,
  noremap = true,
  silent = true
})

api.nvim_buf_set_keymap(0, 'n', "dd", '', {
  callback = actions.delete,
  nowait = true,
  noremap = true,
  silent = true
})

api.nvim_buf_set_keymap(0, 'n', "s", '', {
  callback = actions.split,
  nowait = true,
  noremap = true,
  silent = true
})
