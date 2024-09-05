local extract_filename = function(name, depth)
  local parts = vim.split(vim.fs.normalize(name), "/",
                          {plain = true, trimempty = true})

  return table.concat(parts, "/", #parts - depth)
end

local NameToIndexesMap = {
  new = function(self, opts)
    opts = opts or {}
    local properties = {mappings = {}, depth = opts.depth or 0}

    if opts.handles then self.handles = opts.handles end

    setmetatable(properties, self)
    self.__index = self

    return properties
  end,
  add = function(self, index)
    local name = extract_filename(self.handles[index].name, self.depth)

    if not self.mappings[name] then rawset(self.mappings, name, {}) end

    table.insert(self.mappings[name], index)
  end,
  is_empty = function(self) return vim.tbl_isempty(self.mappings) end,
  iterate = function(self) return pairs(self.mappings) end,
  new_next_level = function(self) return self:new({depth = self.depth + 1}) end
}

local disambiguate
disambiguate = function(names)
  local results = {}
  local collisions = names:new_next_level()

  for name, index_list in names:iterate() do
    if #index_list < 2 then
      results[name] = table.remove(index_list)
    else
      for _, index in ipairs(index_list) do collisions:add(index) end
    end
  end

  if collisions:is_empty() then return results end

  return vim.tbl_extend("error", results, disambiguate(collisions))
end

local get_disambiguated_names = function(handles)
  local names = NameToIndexesMap:new({handles = handles})

  for i, handle in ipairs(handles) do if #handle.name > 0 then names:add(i) end end

  return disambiguate(names)
end

local M = {
  get = function()
    local handles = vim.fn.getbufinfo({buflisted = 1})

    for name, index in pairs(get_disambiguated_names(handles)) do
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

return M
