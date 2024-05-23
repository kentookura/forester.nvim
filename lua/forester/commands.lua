---@tag forester.commands

---@brief [[
---
--- User commands for calling forester from neovim
---
---]]

local util = require("forester.util")
local Forester = require("forester.bindings")
local pickers = require("forester.pickers")
local Config = require("forester.config")
local M = {}

M.commands = {
  config = function()
    Config.switch_config()
  end,
  browse = function()
    local trees = Forester.query_all(vim.g.forester_current_config)
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
    pickers.pick_by_title(t, {})
  end,

  new = function()
    local prefixes = Config.all_prefixes()
    vim.ui.select(prefixes, { -- TODO: Don't select when #all_prefixes == 1
      format_item = function(item)
        return item
      end,
    }, function(choice)
      if choice == nil then
        do
          return
        end
      else
        do
          local path = Config.dir_of_latest_tree_of_prefix(choice)
          local new_tree = Forester.new(choice, path)[1]
          vim.cmd("edit " .. new_tree)
        end
      end
    end)
  end,

  transclude_new = function()
    local prefixes = Config.all_prefixes()
    vim.ui.select(prefixes, { -- TODO: Don't select when #all_prefixes == 1
      format_item = function(item)
        return item
      end,
    }, function(choice)
      if choice == nil then
        do
          return
        end
      else
        do
          local path = Config.dir_of_latest_tree_of_prefix(choice)
          local new_tree = Forester.new(choice, path)[1]
          local addr = util.filename(new_tree):match("(.+)%..+$")
          local content = { "\\transclude{" .. addr .. "}" }
          vim.api.nvim_put(content, "c", true, true)
        end
      end
    end)
  end,

  link_new = function()
    local prefixes = Config.all_prefixes()
    vim.ui.select(prefixes, {
      format_item = function(item)
        return item
      end,
    }, function(choice)
      if choice == nil then
        do
          return
        end
      else
        do
          local path = Config.dir_of_latest_tree_of_prefix(choice)
          local new_tree = Forester.new(choice, path)[1]
          local addr = util.filename(new_tree):match("(.+)%..+$")
          local content = { "[](" .. addr .. ")" } --  NOTE: We should improve the workflow with snippets or something similar
          vim.api.nvim_put(content, "c", true, true)
        end
      end
    end)
  end,
}

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

function M.cmd(cmd)
  local command = M.commands[cmd]
  if command == nil then
    vim.print("Invalid forester command '" .. cmd .. "'")
  else
    command()
  end
end

return M
