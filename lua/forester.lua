local M = {}
local job = require("plenary.job")
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
          print(vim.inspect(data:result()))
          if return_val == 0 then
            print(vim.inspect(data:result()))
          end
        end,
      })
      :sync()
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

vim.api.nvim_create_user_command("ForestNew", new_tree, {})

function M.setup(config)
  vim.filetype.add({ extension = { tree = "tree" } })
  vim.cmd([[
    let b:current_syntax = 'tree'
  ]])

  -- enable opening of forester links
  vim.opt.path:append(tree_dir)
  vim.opt.suffixesadd:prepend(".tree")

  keymap("n", "<leader>nn", new_tree, default_opts)
  require("notify")("forester.nvim loaded")
end

return M
