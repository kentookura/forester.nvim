local vim = vim
local job = require("plenary.job")

local M = {}

local function complete(tree_dir, callback)
  job
    :new({
      command = "forester",
      args = { "complete", tree_dir },
      on_exit = function(data, _)
        vim.schedule(function()
          callback(data)
        end)
      end,
    })
    :sync()
end

local function query(arg, tree_dir, callback)
  job
    :new({
      command = "forester",
      args = { "query", arg, tree_dir },
      on_exit = function(data, _)
        vim.schedule(function()
          callback(data:result())
        end)
      end,
    })
    :sync()
end

local function new(prefix, tree_dir, callback)
  job
    :new({
      command = "forester",
      args = { "new", "--prefix", prefix, "--dir", tree_dir },
      on_exit = function(data, _)
        vim.schedule(function()
          callback(data)
        end)
      end,
    })
    :sync()
end

local function template(pfx, tmpl_addr, tree_dir)
  job
    :new({
      command = "forester",
      args = {
        "new",
        "--prefix",
        pfx,
        "--dir",
        tree_dir,
        "--dest",
        tree_dir,
        "--template",
        tmpl_addr,
      },

      on_exit = vim.schedule_wrap(function(res)
        vim.schedule(function()
          vim.cmd("edit " .. res:result()[1]) -- ugh
        end)
      end),
    })
    :sync()
end

M.query = query
M.new = new
M.template = template
M.complete = complete

return M
