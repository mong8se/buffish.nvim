local extract_filename = function(name, depth)
  local parts = vim.split(vim.fs.normalize(name), "/",
                          {plain = true, trimempty = true})

  return table.concat(parts, "/", #parts - depth)
end

local NameToIndexesMap = {
  new = function(self, depth)
    local properties = {mappings = {}, depth = depth}

    setmetatable(properties, self)
    self.__index = self

    return properties
  end,
  add = function(self, handle, index)
    local name = extract_filename(handle.name, self.depth)

    if not self.mappings[name] then rawset(self.mappings, name, {}) end

    table.insert(self.mappings[name], index)
  end,
  is_empty = function(self) return vim.tbl_isempty(self.mappings) end,
  iterate = function(self) return pairs(self.mappings) end
}

local disambiguate
disambiguate = function(handles, names, depth)
  local results = {}
  local collisions = NameToIndexesMap:new(depth)

  for name, index_list in names:iterate() do
    if #index_list < 2 then
      results[name] = table.remove(index_list)
    else
      for _, index in ipairs(index_list) do
        collisions:add(handles[index], index)
      end
    end
  end

  if collisions:is_empty() then return results end

  return vim.tbl_extend("error", results,
                        disambiguate(handles, collisions, depth + 1))
end

local start_disambiguate = function(handles)
  local names = NameToIndexesMap:new(0)

  for i, handle in ipairs(handles) do
    if #handle.name > 0 then names:add(handle, i) end
  end

  return disambiguate(handles, names, 0)
end

return {
  get = function()
    local handles = vim.fn.getbufinfo({buflisted = 1})
    local names = start_disambiguate(handles)

    for name, index in pairs(names) do
      if handles[index] then handles[index].display_name = name end
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
