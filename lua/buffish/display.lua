local api = vim.api
local session = require("buffish.session")
local shortcuts = require("buffish.shortcuts")
local get_buffer_handles = require("buffish.handles").get

local ns = api.nvim_create_namespace("buffish-ns")

local M = {
  render = function()
    local handles = get_buffer_handles()
    local bufnr = session.get_bufnr()
    session.buf_index = {}

    api.nvim_buf_set_option(bufnr, 'modifiable', true)
    api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

    for i, buffer in ipairs(handles) do
      -- if not api.nvim_buf_is_valid(buffer.bufnr) then break end
      if buffer and buffer.display_name and buffer.bufnr then
        local row = i - 1

        session.buf_index[i] = buffer.bufnr

        api.nvim_buf_set_lines(bufnr, row, i, false, {buffer.name})

        local filename = vim.fn.fnamemodify(buffer.display_name, ":t")

        api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
          virt_text = {{tostring(buffer.bufnr), "Comment"}},
          virt_text_pos = "right_align",
          end_col = #buffer.name - #buffer.display_name,
          hl_group = "Normal",
          conceal = " "
        })

        api.nvim_buf_set_extmark(bufnr, ns, row,
                                 #buffer.name - #buffer.display_name, {
          hl_group = "Directory",
          end_col = #buffer.name - #filename
        })

        api.nvim_buf_set_extmark(bufnr, ns, row, #buffer.name - #filename, {
          hl_group = "Identifier",
          end_col = #buffer.name
        })

        local key = shortcuts.get(buffer.bufnr)
        if key then
          api.nvim_buf_set_extmark(bufnr, ns, row, 0, {sign_text = key})
        end
      end
    end

    api.nvim_buf_set_option(bufnr, 'modified', false)
    api.nvim_buf_set_option(bufnr, 'modifiable', false)
  end,

  safely_set_cursor = function(loc)
    api.nvim_win_set_cursor(0, {
      math.min(api.nvim_buf_line_count(session.get_bufnr()), loc), 0
    })
  end
}

return M
