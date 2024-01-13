local forester = require("forester.bindings")
local ui = vim.ui

local M = {}

local function open_tree(tree_dir)
  -- TODO: check if i am in a forest, then check configured tree dirs.
  local function select(data)
    ui.select(data, {
      prompt = "Select a tree title",
      format_item = function(item)
        -- local addr = item:match("[^, ]*$")
        -- local title = item:match("[^,]+$")
        return item
      end,
    }, function(choice)
      if choice == nil then
        return
      end
      local addr = choice:match("[^,%s]+")
      local path = vim.fn.findfile(addr .. ".tree", tree_dir .. "/**")
      vim.cmd("edit " .. path)
    end)
  end

  forester.complete(tree_dir, select)
end

M.open_tree = open_tree

return M
