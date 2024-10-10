local forester = require("forester.bindings")
local path = require("plenary.path")
local expect, eq = MiniTest.expect, MiniTest.expect.equality
local T = MiniTest.new_set()

local test_forest = path:new("test_forest")
local cfg = path:new("forest.toml")

local clean_test_forest = function()
  path.rmdir(test_forest)
  path.rm(cfg)
end

local setup_test_forest = function()
  local p = path:new("trees")
  p:mkdir()
  cfg:write(
    '[forest]\
trees = ["trees"]\
prefixes = ["test"]',
    "w",
    438
  )
end

T["bindings"] = MiniTest.new_set({ hooks = { pre_once = setup_test_forest, post_once = clean_test_forest } })

T["bindings"]["config"] = function() end

T["bindings"]["build"] = function()
  local res = forester.build("forest.toml", { no_assets = true, no_theme = true })
  eq(res, {})
end

T["bindings"]["new_tree"] = function() end

return T
