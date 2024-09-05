local actions = require("buffish.actions")

local api = vim.api
local w = vim.w
local wo = vim.wo
local bo = vim.bo

bo.buflisted = false
bo.bufhidden = 'wipe'
bo.buftype = 'nofile'
bo.swapfile = false

local augroup = api.nvim_create_augroup('buffish-au', {clear = true})

api.nvim_create_autocmd("BufWinEnter", {
  buffer = 0,
  callback = function()
    w.buffish_saved_conceallevel = wo.conceallevel
    wo.conceallevel = 1

    w.buffish_saved_concealcursor = wo.concealcursor
    wo.concealcursor = "nic"

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
  end,
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

api.nvim_buf_set_keymap(0, 'n', "a", '', {
  callback = actions.assign_shortcut,
  nowait = true,
  noremap = true,
  silent = true
})

api.nvim_buf_set_keymap(0, 'n', "r", '', {
  callback = actions.remove_shortcut,
  nowait = true,
  noremap = true,
  silent = true
})
