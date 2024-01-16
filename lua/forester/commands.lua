---@tag forester.commands

---@brief [[
---
--- User commands for calling forester from neovim
---
---]]

local util = require("forester.util")
local Path = require("plenary.path")
local Scan = require("plenary.scandir")
local forester = require("forester.bindings")
local navigation = require("forester.navigation")
local M = {}

local contains_match = function(tbl, str)
  for _, v in ipairs(tbl) do
    if v:match(str) then
      return true
    end
  end
  return false
end

local contains = function(tbl, str)
  for _, v in ipairs(tbl) do
    if v == str then
      return true
    end
  end
  return false
end

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

local function available_tree_dirs(opts)
  local configured_tree_dirs = util.map(opts.tree_dirs, function(dir)
    return "./" .. Path:new({ dir, sep = "/" }):normalize()
  end)

  local local_dirs = Scan.scan_dir(".", { depth = 1, only_dirs = true })

  local local_tree_dirs = util.filter(local_dirs, function(dir)
    return contains(configured_tree_dirs, dir)
  end)
  return local_tree_dirs
end

M.commands = {
  browse = function(opts)
    -- NOTE: It would be nice to get the path info for trees directly
    -- from forester. This is not implemented at the time.

    local dirs = available_tree_dirs(opts)
    if #dirs > 1 then
      do
        print("found multiple tree directories in current directory.")
      end
    end
    local all_trees = {}
    for _, tree_dir in pairs(dirs) do
      local trees = forester.titles(tree_dir)
      for k, v in pairs(trees) do
        all_trees[k] = v
      end
    end
    --vim.print(vim.inspect(all_trees))
    navigation.pick_tree(all_trees, {})
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
    vim.print("Invalid forester command '" .. cmd .. "'")
  else
    command(opts)
  end
end

return M
