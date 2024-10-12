package.path = package.path .. ";./?.lua"

local forester = require("forester.bindings")
local expect, eq = MiniTest.expect, MiniTest.expect.equality
local T = MiniTest.new_set()
local hooks = require("tests.hooks")

T["bindings"] =
  MiniTest.new_set({ hooks = { pre_once = hooks.setup_test_forest, post_once = hooks.clean_test_forest } })

T["bindings"]["build"] = function()
  local res = forester.build("forest.toml", { no_assets = true, no_theme = true })
  eq(res, {})
end

T["bindings"]["titles"] = function()
  local res = forester.titles(vim.g.forester_current_config)
  eq(res, { t3 = "asdf" })
end

T["bindings"]["new"] = function()
  local res = forester.new("foo", "trees", vim.g.forester_current_config)
  eq(res, { "trees/foo-0002.tree" })
end

T["bindings"]["new_tree"] = function() end

return T
