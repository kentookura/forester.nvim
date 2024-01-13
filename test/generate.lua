local generate = require("forester.generate")
local scan = require("plenary.scandir")

local idx = 1

local cases = {
  function()
    generate.new_from_template()
  end,
  function()
    generate.new_tree()
  end,
  function()
    generate.transclude_new_tree()
  end,
  function()
    generate.link_new_tree()
  end,
}

local function next()
  local opts = cases[idx]
  if opts then
    idx = idx + 1
  end
end

next()
