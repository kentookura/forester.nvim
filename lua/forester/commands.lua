local M = {}

function M.parse(args)
  local parts = vim.split(vim.trim(args), "%s+")
  if parts[1]:find("Forester") then
    table.remove(parts, 1)
  end

  if args:sub(-1) == " " then
    parts[#parts + 1] = ""
  end
  return table.remove(parts, 1) or "", parts
end

M.commands = {
  new = function(opts)
    vim.print(vim.inspect(opts))
  end,
  transclude = function(opts)
    vim.print(vim.inspect(opts))
  end,
  link = function(opts)
    vim.print(vim.inspect(opts))
  end,
}

function M.cmd(cmd, opts)
  local command = M.commands[cmd]
  if command == nil then
    vim.print("Invalid forester commad '" .. cmd .. "'")
  else
    command(opts)
  end
end

return M
