--This file should contain all commands meant to be used by mappings.
local cc = require("neo-tree.sources.common.commands")
local manager = require("neo-tree.sources.manager")

local vim = vim

local M = {}

M.new_tree = function(state)
  local tree = state.tree
  local node = tree:get_node()
  local id = node:get_id()
  local name = node.name
  print(string.format(": id=%s, name=%s", id, name))
end

M.refresh = function(state)
  manager.refresh("example", state)
end

M.show_debug_info = function(state)
  print(vim.inspect(state))
end

cc._add_common_commands(M)
return M
