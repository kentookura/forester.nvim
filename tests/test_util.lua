local T = MiniTest.new_set()
local expect, eq = MiniTest.expect, MiniTest.expect.equality

local util = require("forester.util")

T["pad_addr"] = function()
  eq("0001", util.pad_addr(1))
  eq("01TA", util.pad_addr(2350))
end

T["next_addr"] = function()
  eq("foo-0002", util.inc_addr("foo", 1))
  eq("foo-000A", util.inc_addr("foo", 9))
  eq("foo-000F", util.inc_addr("foo", 14))
  eq("foo-1000", util.inc_addr("foo", 46655)) -- base36: ZZZ
end

T["prev_addr"] = function()
  eq("foo-0001", util.decr_addr("foo", 2))
  eq("foo-0009", util.decr_addr("foo", 10))
  eq("foo-000D", util.decr_addr("foo", 14))
  eq("foo-0ZZY", util.decr_addr("foo", 46655)) -- base36: ZZZ
end

return T
