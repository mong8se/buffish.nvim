return {
  get = function(buffer)
    if not _G.MiniIcons then return end

    local text, hl, is_default

    if vim.fn.isdirectory(buffer.name) == 1 then
      text, hl = _G.MiniIcons.get('directory', vim.fs.basename(buffer.name))
    else
      text, hl, is_default = _G.MiniIcons.get('file', buffer.name)
      if is_default then
        text, hl = _G.MiniIcons.get('filetype', vim.bo[buffer.bufnr].filetype)
      end
    end

    return {sign_text = text, sign_hl_group = hl}
  end
}
