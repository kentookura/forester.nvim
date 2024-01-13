local M = {}

local bindings = require("forester.bindings")

--@class ForestConfig
local ForestConfig = {}

function ForestConfig:new()
  -- local config = Config.get_default_config()
  local config = {}
  local forest = setmetatable({ forests = { "~/notes", "docs", "trees" } }, self)
  return forest
end

local config = ForestConfig:new()

--local function list_all_trees(c)
--  for forest in c.forests do
--    bindings.list_trees(forest, vim.print)
--  end
--end
--
--list_all_trees(config)

function M.get_default_config()
  return { settings = {}, trees = {} }
end

return M
