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
  local tree_dirs = opts.tree_dirs
  local configured_tree_dirs = util.map(tree_dirs, function(dir)
    return "./" .. Path:new({ dir, sep = "/" }):normalize()
  end)

  local local_dirs = Scan.scan_dir(".", { depth = 1, only_dirs = true })

  local local_tree_dirs = util.filter(local_dirs, function(dir)
    return contains(configured_tree_dirs, dir)
  end)
  return local_tree_dirs
end

local function all_prefixes(opts)
  local dirs = available_tree_dirs(opts)
  local out = {}
  for _, tree_dir in pairs(dirs) do
    local trees = forester.query("prefix", tree_dir)
    for k, v in pairs(trees) do
      out[k] = { prefix = v, dir = tree_dir }
    end
  end
  return out
end

local function all_trees(opts)
  local dirs = available_tree_dirs(opts)
  local all_trees = {}
  for _, tree_dir in pairs(dirs) do
    local trees = forester.query_all(tree_dir)
    for k, v in pairs(trees) do
      all_trees[k] = v
    end
  end
  return all_trees
end

M.commands = {
  preview = function(opts)
    forester.build(opts)
  end,
  tag = function(opts)
    forester.query("tags")
  end,
  watch = function(opts)
    return { start = forester.build(opts), stop = forester.build(opts) }
  end,
  build = function(opts)
    forester.build(opts)
  end,
  browse = function(opts)
    local trees = all_trees(opts)
    local t = {}
    for k, v in pairs(trees) do
      v.addr = k
      table.insert(t, v)
    end
    if #t == 0 then
      do
        vim.print("No trees found!")
      end
    end
    -- elseif #trees == 1 then
    --   do
    --     local path = trees[1].addr .. ".tree"
    --     vim.print("Only found one tree. Opening...")
    --     vim.cmd("edit " .. vim.fn.findfile(path))
    --   end
    -- else
    --   do
    -- vim.print(vim.inspect(t[1]))
    --   end
    -- end
    local ts = util.filter(t, function(tree)
      return tree.title ~= vim.NIL
    end)
    navigation.pick_by_title(ts, {})
  end,

  new = function(opts)
    local prefixes = all_prefixes(opts)

    -- if #prefixes = 0 then do

    vim.ui.select(prefixes, { -- TODO: Don't select when #all_prefixes == 1
      format_item = function(item)
        return item.prefix
      end,
    }, function(choice)
      local path = forester.new(choice.prefix, choice.dir)[1]
      vim.cmd("edit " .. path)
    end)
  end,

  transclude = function(opts)
    local prefixes = all_prefixes(opts)
    vim.ui.select(prefixes, { -- TODO: Don't select when #all_prefixes == 1
      format_item = function(item)
        return item.prefix
      end,
    }, function(choice)
      local path = forester.new(choice.prefix, choice.dir)[1]
      local _, addr, _ = util.split_path(path)
      local content = { "\\transclude{" .. addr .. "}" }
      vim.api.nvim_put(content, "c", true, true)
    end)
  end,

  info = function(opts)
    vim.notify(vim.inspect(opt))
  end,

  link = function(opts)
    local prefixes = all_prefixes(opts)
    vim.ui.select(prefixes, {
      format_item = function(item)
        return item.prefix
      end,
    }, function(choice)
      local path = forester.new(choice.prefix, choice.dir)[1]
      local _, addr, _ = util.split_path(path)
      local content = { "[](" .. addr .. ")" } --  NOTE: We should improve the workflow with snippets or something similar
      vim.api.nvim_put(content, "c", true, true)
    end)
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
