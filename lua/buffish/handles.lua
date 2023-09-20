local extract_filename = function(name, depth)
  local parts = vim.split(vim.fs.normalize(name), "/",
                          {plain = true, trimempty = true})

  return table.concat(parts, "/", #parts - depth)
end

local add_name_to_index_mapping = function(handle, list, bufi, depth)
  local name = extract_filename(handle.name, depth)

  list[name] = list[name] or {}
  table.insert(list[name], bufi)

  return list
end

local disambiguate
disambiguate = function(handles, names, depth)
  depth = depth or 0

  if not names then
    names = {}
    for i, handle in ipairs(handles) do
      add_name_to_index_mapping(handle, names, i, depth)
    end
  end

  local collisions = {}
  local results = {}

  depth = depth + 1

  for name, bufl in pairs(names) do
    if #bufl < 2 then
      results[name] = names[name]
    else
      for _, bufi in ipairs(bufl) do
        add_name_to_index_mapping(handles[bufi], collisions, bufi, depth)
      end
    end
  end

  if vim.tbl_isempty(collisions) then return results end

  return vim.tbl_extend("error", results,
                        disambiguate(handles, collisions, depth))
end

return {
  get = function()
    local handles = vim.tbl_filter(function(buffer) return #buffer.name > 0 end,
                                   vim.fn.getbufinfo({buflisted = 1}))
    local names = disambiguate(handles)

    for name, bufl in pairs(names) do
      for _, bufi in ipairs(bufl) do
        if handles[bufi] then handles[bufi].display_name = name end
      end
    end

    table.sort(handles, function(a, b)
      if a.lastused == b.lastused then
        return a.bufnr < b.bufnr
      else
        return a.lastused > b.lastused
      end
    end)

    return handles
  end
}
