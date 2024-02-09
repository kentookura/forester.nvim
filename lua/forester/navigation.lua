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
    end
  end

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = widths.title },
      { width = widths.addr },
    },
  })
  local make_display = function(item)
    return displayer({
      { item.title }, -- TODO: Figure out highlight groups
      { item.addr },
    })
  end
  local entry_maker = function(entry)
    entry.value = entry.addr
    entry.ordinal = entry.title
    entry.display = make_display
    return entry
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
          local search_path = selection.dir .. "/.*"
          local file = vim.fn.findfile(selection.addr .. ".tree", search_path)
          vim.cmd("edit " .. file)
        end)
        return true
      end,
    })
    :find()
end

M.pick_by_title = pick_by_title

return M
