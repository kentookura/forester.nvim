package.path = package.path .. ";./?.lua"

local path = require("plenary.path")
local map = require("forester.util").map
local config = require("forester.config")
local expect, eq = MiniTest.expect, MiniTest.expect.equality
local hooks = require("tests.hooks")

local T = MiniTest.new_set({ hooks = { pre_once = hooks.setup_test_forest, post_once = hooks.clean_test_forest } })

-- local config_path = path:new("forest.toml")

T["config"] = function()
  local parsed = config.parse("forest.toml")

  eq(parsed, { trees = { "trees", "foo", "bar" }, prefixes = { "test", "pfx" } })
end

return T
