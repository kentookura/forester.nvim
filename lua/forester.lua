local M = {}
local job = require("plenary.job")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local tree_dir = "trees"
local keymap = vim.keymap.set
local default_opts = { noremap = true, silent = true }

local _config = {}

local function select_prefixes(pfx)
  vim.ui.select(pfx, {}, function(choice)
    job
      :new({
        command = "forester",
        args = { "new", "--prefix", choice, "--dir", tree_dir },
        on_exit = function(data, return_val)
          vim.schedule(function()
            vim.cmd("edit " .. data:result()[1])
          end)
        end,
      })
      :sync()
  end)
end

local function select_from_title(data)
  vim.ui.select(data, {
    prompt = "Titles",
    format_item = function(item)
      return item:match("[^,]+$")
    end,
  }, function(choice)
    local addr = choice:match("[^,%s]+")
    -- match until :    [^,]+(?=,)
    --get after:          [^, ]*$
    local path = tree_dir .. "/" .. addr .. ".tree"
    vim.cmd("edit " .. path)
  end)
end

local function new_tree()
  job
    :new({
      command = "forester",
      args = { "query", "prefix", tree_dir },
      on_exit = vim.schedule_wrap(function(j, _)
        select_prefixes(j:result())
      end),
    })
    :sync()
end

local function open_tree()
  job
    :new({
      command = "forester",
      args = { "complete", tree_dir },
      on_exit = vim.schedule_wrap(function(j, _)
        select_from_title(j:result())
      end),
    })
    :sync()
  opts = opts or {}
  --
end

vim.api.nvim_create_user_command("ForestNew", new_tree, {})
vim.api.nvim_create_user_command("Forestpen", open_tree, {})

function M.setup(config)
  vim.filetype.add({ extension = { tree = "tree" } })
  vim.cmd([[
    let b:current_syntax = 'tree'
  ]])

  -- enable opening of forester links
  vim.opt.path:append(tree_dir)
  vim.opt.suffixesadd:prepend(".tree")

  keymap("n", "<leader>nn", new_tree, default_opts)
  keymap("n", "<leader>n.", open_tree, default_opts)
  require("notify")("forester.nvim loaded")
end

return M
