---@tag forester.commands

---@brief [[
---
--- User commands for calling forester from neovim
---
---]]

local util = require("forester.util")
local forester = require("forester.bindings")
local navigation = require("forester.navigation")
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

local function all_prefixes()
  local dirs = forester.tree_dirs("forest.toml")
  local out = {}
  for _, tree_dir in pairs(dirs) do
    local trees = forester.query("prefix")
    for k, v in pairs(trees) do
      out[k] = { prefix = v, dir = tree_dir }
    end
  end
  return out
end

M.commands = {
  preview = function()
    forester.build()
  end,
  tag = function()
    forester.query("tags")
  end,
  watch = function()
    return { start = forester.build(), stop = forester.build() }
  end,
  build = function()
    forester.build()
  end,
  browse = function()
    local trees = forester.query_all()
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
    local ts = util.filter(t, function(tree)
      return tree.title ~= vim.NIL
    end)
    navigation.pick_by_title(ts, {})
  end,

  new = function()
    local prefixes = all_prefixes()
    vim.ui.select(prefixes, { -- TODO: Don't select when #all_prefixes == 1
      format_item = function(item)
        return item.prefix
      end,
    }, function(choice)
      if choice == nil then
        do
          return
        end
      else
        do
          local path = forester.dir_of_latest_tree_of_prefix("forest.toml", choice.prefix)
          local new_tree = forester.new(choice.prefix, path)[1]
          vim.cmd("edit " .. new_tree)
        end
      end
    end)
  end,

  transclude = function()
    local prefixes = all_prefixes()
    vim.ui.select(prefixes, { -- TODO: Don't select when #all_prefixes == 1
      format_item = function(item)
        return item.prefix
      end,
    }, function(choice)
      if choice == nil then
        do
          return
        end
      else
        do
          local path = forester.dir_of_latest_tree_of_prefix("forest.toml", choice.prefix)
          local new_tree = forester.new(choice.prefix, choice.dir)[1]
          local _, addr, _ = util.split_path(path)
          local content = { "\\transclude{" .. addr .. "}" }
          vim.api.nvim_put(content, "c", true, true)
        end
      end
    end)
  end,

  info = function() end,

  link = function()
    local prefixes = all_prefixes()
    vim.ui.select(prefixes, {
      format_item = function(item)
        return item.prefix
      end,
    }, function(choice)
      local path = forester.dir_of_latest_tree_of_prefix("forest.toml", choice.prefix)
      local new_tree = forester.new(choice.prefix, choice.dir)[1]
      local content = { "[](" .. addr .. ")" } --  NOTE: We should improve the workflow with snippets or something similar
      vim.api.nvim_put(content, "c", true, true)
    end)
  end,
}

function M.cmd(cmd)
  local command = M.commands[cmd]
  if command == nil then
    vim.print("Invalid forester command '" .. cmd .. "'")
  else
    command()
  end
end

return M
