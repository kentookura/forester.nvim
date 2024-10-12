local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality
local completion = require("forester.completion")

local T = new_set()

-- Actual tests definitions will go here

T["closing delimiters"] = function()
  eq(completion:closing_delim("\\transclude{foo"), "}")
  eq(completion:closing_delim("abcdefg \\import{123-"), "}")
  eq(completion:closing_delim("safd \\author{"), "}")
  eq(completion:closing_delim("[testing it](foo-00"), ")")
  eq(completion:closing_delim("dfsfdadf[[wikilinks"), "]]")
end

return T
