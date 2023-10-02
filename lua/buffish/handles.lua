local extract_filename = function(name, depth)
  local parts = vim.split(vim.fs.normalize(name), "/",
                          {plain = true, trimempty = true})

  return table.concat(parts, "/", #parts - depth)
end

local new_map = function(depth)
  local mappings = {}

  setmetatable(mappings, {
    __newindex = function(self, handle, bufi)
      local name = extract_filename(handle.name, depth)

      if not self[name] then rawset(self, name, {}) end

      table.insert(self[name], bufi)
    end
  })

  return mappings
end

local disambiguate
disambiguate = function(handles, names, depth)
  depth = depth or 0

  if not names then
    names = new_map(depth)
    for i, handle in ipairs(handles) do
      if #handle.name > 0 then names[handle] = i end
    end
  end

  depth = depth + 1

  local results = {}
  local collisions = new_map(depth)

  for name, bufl in pairs(names) do
    vim.print(name, bufl)
    if #bufl < 2 then
      results[name] = names[name]
    else
      for _, bufi in ipairs(bufl) do collisions[handles[bufi]] = bufi end
    end
  end

  if vim.tbl_isempty(collisions) then return results end

  return vim.tbl_extend("error", results,
                        disambiguate(handles, collisions, depth))
end

return {
  get = function()
    local handles = vim.fn.getbufinfo({buflisted = 1})
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
