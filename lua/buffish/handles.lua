local safely_insert = function(list, entry)
  list = list or {}
  table.insert(list, entry)
  return list
end

local extract_filename = function(name, depth)
  -- replace \ with / for windows paths..
  if package.config:sub(1, 1) == '\\' then name = name:gsub("\\", "/") end
  local parts = vim.split(name, "/", {plain = true, trimempty = true})

  local filename = string.format(string.rep("%s", depth + 1, "/"),
                                 unpack(parts, #parts - depth))

  return filename
end

local disambiguate
disambiguate = function(handles, names, depth)
  local matches_found = false
  local results = {}

  for name, bufl in pairs(names) do
    if #bufl < 2 then
      results[name] = names[name]
    else
      matches_found = true
      for _, bufi in ipairs(bufl) do
        local filename = extract_filename(handles[bufi].name, depth)
        results[filename] = safely_insert(results[filename], bufi)
      end
    end
  end

  if matches_found then
    return disambiguate(handles, results, depth + 1)
  else
    return results
  end
end

return {
  get = function()
    local handles = {}
    local names = {}

    for i, buffer in ipairs(vim.fn.getbufinfo({buflisted = 1})) do
      if #buffer.name > 0 then
        table.insert(handles, buffer)
        local filename = extract_filename(buffer.name, 0)
        names[filename] = safely_insert(names[filename], i)
      end
    end

    names = disambiguate(handles, names, 1)

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
