local forester = require("forester")
local commands = require("forester.commands").commands
local expect, eq = MiniTest.expect, MiniTest.expect.equality
local child = MiniTest.new_child_neovim()
local hooks = require("tests.hooks")

local T = MiniTest.new_set({
  hooks = {
    pre_once = function()
      hooks.setup_test_forest()
    end,
    pre_case = function()
      child.restart({ "-u", "scripts/minimal_init.lua" })
      child.bo.readonly = false
      child.lua([[
        require('forester').setup()
        commands = require('forester.commands').commands
      ]])
    end,
    post_once = function()
      child.stop()
      -- hooks.clean_test_forest()
    end,
  },
})

T["browse"] = function()
  expect.no_error(function()
    child.lua([[commands.browse()]])
  end)
end

T["build"] = function()
  expect.no_error(function()
    child.lua([[commands.build()]])
  end)
end

T["config"] = function()
  expect.no_error(function()
    child.lua([[commands.config()]])
  end)
end

-- TODO: figure out how to test commands that modify the buffer
T["link_new"] = function()
  expect.no_error(function()
    -- child.lua([[commands.link_new()]])
  end)
end

T["new"] = function()
  expect.no_error(function()
    -- child.lua([[commands.new()]])
  end)
end

T["new_random"] = function()
  expect.no_error(function()
    -- child.lua([[commands.new_random()]])
  end)
end

T["transclude_new"] = function()
  expect.no_error(function()
    -- child.lua([[commands.transclude_new()]])
  end)
end

return T
