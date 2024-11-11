local shortcuts = require("buffish.shortcuts")
local get_handles = require("buffish.handles").get
local get_icon = require("buffish.icons").get

local api = vim.api

local ns = api.nvim_create_namespace("buffish-ns")

return {
  render = function(bufnr)
    local handles = get_handles()
    local buffish_index = {}

    vim.bo[bufnr].modifiable = true
    api.nvim_buf_set_lines(bufnr, 0, -1, false,
                           vim.iter(handles):map(function(buffer)
      return #buffer.name > 0 and buffer.name or " [No Name]"
    end):totable())

    for i, buffer in ipairs(handles) do
      table.insert(buffish_index, buffer.bufnr)

      local set_extmark = function(col, opts)
        api.nvim_buf_set_extmark(bufnr, ns, i - 1, col, opts)
      end

      if buffer.display_name then
        local display_name = buffer.display_name

        local ending = string.match(buffer.name, "([\\/])$")
        if ending then display_name = display_name .. ending end

        local file_name = vim.fs.basename(display_name)

        set_extmark(0, {
          hl_group = "Normal",
          end_col = #buffer.name - #display_name,
          conceal = buffer.changed > 0 and "+" or " "
        })

        set_extmark(#buffer.name - #display_name, {
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
      local sign = key and {sign_text = key} or get_icon(buffer)

      if sign then set_extmark(0, sign) end
    end

    vim.b[bufnr].buffish_index = buffish_index
    vim.bo[bufnr].modified = false
    vim.bo[bufnr].modifiable = false
  end
}
