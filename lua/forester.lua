local M = {}
local job = require("plenary.job")

local _config = {}

function M.setup(config)
  vim.filetype.add({ extension = { tree = "tree" } })
  vim.cmd([[
    let b:current_syntax = 'tree'
  ]])
  require("notify")("forester.nvim loaded")
end

local function select_prefixes(pfx)
  vim.ui.select(pfx, {}, function(choice)
    job
      :new({
        command = "forester",
        args = { "new", "--prefix", choice, "--dir", "trees" },
        on_exit = function(data, return_val)
          print(vim.inspect(data:result()))
          if return_val == 0 then
            print(vim.inspect(data:result()))
          else
            print("error")
          end
        end,
      })
      :sync()
  end)
end

vim.api.nvim_create_user_command("Forest", function()
  job
    :new({
      command = "forester",
      args = { "query", "prefix", "trees" },
      on_exit = vim.schedule_wrap(function(j, _)
        select_prefixes(j:result())
      end),
    })
    :sync()
end, {})

return M
