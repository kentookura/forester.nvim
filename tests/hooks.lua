local path = require("plenary.path")
local config = require("forester.config")

local M = {}

local dirs = { "trees", "foo", "bar" }
local cfg = path:new("forest.toml")
local t1 = path:new("trees/foo-0001.tree")
local t2 = path:new("trees/t2.tree")
local t3 = path:new("trees/t3.tree")

local clean_test_forest = function()
  for _, dir in pairs(dirs) do
    path:new(dir):rm({ recursive = true })
  end
  path.rm(cfg)
end

local setup_test_forest = function()
  for _, dir in pairs(dirs) do
    path:new(dir):mkdir()
  end
  cfg:write(
    '[forest]\
trees = ["trees", "foo", "bar"]\
prefixes = ["test", "pfx"]',
    "w",
    438
  )
  t1:write("\\transclude{t2}", "w")
  t2:write("[asdf](t3)", "w", 438)
  t3:write("\\title{asdf}", "w", 438)
  -- vim.g.forester_current_config = config.parse("forest.toml")
end

M.clean_test_forest = clean_test_forest
M.setup_test_forest = setup_test_forest
return M
