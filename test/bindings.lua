local forester = require("forester.bindings")
local util = require("forester.util")
local scan = require("plenary.scandir")

local tree_dir = "test/trees"

describe("forester bindings", function()
  describe("complete", function()
    it("works", function()
      assert(
        vim.deep_equal(
          forester.complete(tree_dir),
          { { addr = "foo-0001", title = "foo" }, { addr = "foo-0002", title = "bar" } }
        )
      )
    end)
  end)
  describe("query", function()
    it("works", function()
      assert(vim.deep_equal(forester.query("prefix", tree_dir), { "foo" }))
    end)
  end)
  describe("new", function()
    it("creates a new tree", function()
      local count = 0
      local dirs = scan.scan_dir(tree_dir, {
        on_insert = function()
          count = count + 1
        end,
      })
      forester.new("foo", tree_dir, function(res) end)
      local scan_again = scan.scan_dir(tree_dir, {})
      assert(count + 1 == #scan_again)
    end)
  end)
  describe("template", function()
    it("works", function()
      --forester.template("foo", "test", "test")
    end)
  end)
end)
