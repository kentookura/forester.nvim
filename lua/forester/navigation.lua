local strings = require("plenary.strings")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")

local M = {}

local pick_by_title = function(trees, opts)
  opts = opts or {}
  local widths = { title = 0, addr = 0 }

  for _, tree in pairs(trees) do
    for k, v in pairs(widths) do
      widths[k] = math.max(v, strings.strdisplaywidth(tree[k]))
      -- widths[k] = 50
    end
  end

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = widths.title },
      { width = widths.addr },
    },
  })

  local make_display = function(item) -- NOTE: item is the table returned by entry_maker
    return displayer({
      { item.title }, --  TODO: Figure out highlight groups
      { item.addr },
    })
  end

  local entry_maker = function(entry)
    return { --
      value = entry,
      display = make_display,
      ordinal = entry.title,
      title = entry.title,
      addr = entry.addr,
      sourcePath = entry.sourcePath,
    }
  end

  pickers
    .new(opts, {
      prompt_title = "Pick a tree",
      finder = finders.new_table({
        results = trees,
        entry_maker = entry_maker,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.cmd("edit " .. selection.sourcePath)
        end)
        return true
      end,
    })
    :find()
end

M.pick_by_title = pick_by_title

-- local forester = require("forester.bindings")
-- local trees = (forester.query_all("trees"))
-- local t = {}
--
-- for k, v in pairs(trees) do
--   v.addr = k
--   table.insert(t, v)
-- end

-- vim.print(vim.inspect(t))
-- vim.print(#t)
-- pick_by_title(t, {})

return M
