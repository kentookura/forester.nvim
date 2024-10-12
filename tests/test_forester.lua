package.path = package.path .. ";./?.lua"

local hooks = require("tests.hooks")
local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

local forester = require("forester")

local T = MiniTest.new_set({ hooks = { pre_once = hooks.setup_test_forest, post_once = hooks.clean_test_forest } })

T["setup"] = function()
  expect.no_error(function()
    forester.setup()
  end)
end

T["treesitter"] = function()
  expect.no_error(function()
    forester.register_treesitter_parser()
  end)
end

return T
