local generate = require("forester.generate")
local scan = require("plenary.scandir")

local idx = 1

local cases = {
  function() end,
}

local function next()
  local opts = cases[idx]
  if opts then
    idx = idx + 1
  end
end

next()
