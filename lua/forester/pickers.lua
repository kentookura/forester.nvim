local config = require("forester.config")
local strings = require("plenary.strings")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")

local M = {}

local pick_config = function(config_files, opts)
  opts = opts or {}

  pickers
    .new(opts, {
      prompt_title = "Pick a config",
      finder = finders.new_table({
        results = config_files,
        --entry_maker = entry_maker,
      }),
      previewer = previewers.vim_buffer_cat.new(opts),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.g.forester_current_config = config.parse(selection[1])
        end)
        return true
      end,
    })
    :find()
end

local pick_by_title = function(trees, opts)
  opts = opts or {}
  local widths = { title = 0, addr = 0 }

  for _, tree in pairs(trees) do
    for k, v in pairs(widths) do
      widths[k] = math.max(v, strings.strdisplaywidth(tree[k]), ("<untitled>"):len())
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
    local title
    if item.title == vim.NIL or item.title == nil then
      do
        title = "<untitled>"
      end
    else
      title = item.title
    end

    return displayer({
      { title }, --  TODO: Figure out highlight groups
      { item.addr },
    })
  end

  local entry_maker = function(entry)
    return {
      value = entry,
      display = make_display,
      ordinal = entry.title,
      title = entry.title,
      addr = entry.addr,
      -- FIXME:
      -- https://github.com/nvim-telescope/telescope.nvim/blob/eae0d8fbde590b0eaa2f9481948cd6fd7dd21656/lua/telescope/from_entry.lua#L14
      -- If this is nil, telescope ends up passing `value` to `path_expand`,
      -- which is a table and thus fails. Ultimately, we should be taking
      -- care to filter out trees that have no sourcePath, as we cannot open
      -- them in the editor.
      filename = entry.sourcePath or "",
    }
  end

  pickers
    .new(opts, {
      prompt_title = "Pick a tree",
      finder = finders.new_table({
        results = trees,
        entry_maker = entry_maker,
      }),
      previewer = previewers.vim_buffer_cat.new(opts),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.cmd("edit " .. selection.filename)
        end)
        return true
      end,
    })
    :find()
end

M.pick_by_title = pick_by_title
M.pick_config = pick_config

return M
