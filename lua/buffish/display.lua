local api = vim.api
local session = require("buffish.session")
local shortcuts = require("buffish.shortcuts")

local ns = api.nvim_create_namespace("buffish-ns")

local M
M = {
  render = function()
    local handles = session.get_buffer_handles()
    local bufnr = session.get_bufnr()

    vim.bo[bufnr].modifiable = true
    api.nvim_buf_set_lines(bufnr, 0, -1, false,
                           vim.iter(handles):map(function(buffer)
      return #buffer.name > 0 and buffer.name or " [No Name]"
    end):totable())

    for i, buffer in ipairs(handles) do
      local set_extmark = function(col, opts)
        api.nvim_buf_set_extmark(bufnr, ns, i - 1, col, opts)
      end

      if buffer.display_name then
        local file_name = vim.fs.basename(buffer.display_name)

        set_extmark(0, {
          hl_group = "Normal",
          end_col = #buffer.name - #buffer.display_name,
          conceal = buffer.changed > 0 and "+" or " "
        })

        set_extmark(#buffer.name - #buffer.display_name, {
          hl_group = "Directory",
          end_col = #buffer.name - #file_name
        })

        set_extmark(#buffer.name - #file_name,
                    {hl_group = "Identifier", end_col = #buffer.name})
      end

      set_extmark(0, {
        virt_text = {{tostring(buffer.bufnr), "Comment"}},
        virt_text_pos = "right_align"
      })

      local key = shortcuts.get(buffer.bufnr)
      if key then set_extmark(0, {sign_text = key}) end
    end

    vim.bo[bufnr].modified = false
    vim.bo[bufnr].modifiable = false
  end,

  safely_set_cursor = function(row)
    local win = vim.fn.getwininfo(vim.fn.win_getid())[1]

    if win.bufnr == session.get_bufnr() then
      api.nvim_win_set_cursor(win.winid, {
        math.min(api.nvim_buf_line_count(win.bufnr), row), 0
      })
    end
  end,

  rerender = function()
    local old_line = api.nvim_win_get_cursor(0)[1]
    vim.schedule(function()
      M.render()
      M.safely_set_cursor(old_line)
    end)
  end
}

return M
