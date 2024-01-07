local vim = vim
local job = require("plenary.job")

local Bindings = {}

local function complete(tree_dir, callback)
  job
    :new({
      command = "forester",
      args = { "complete", tree_dir },
      on_exit = function(data, _)
        vim.schedule(function()
          callback(data:result())
        end)
      end,
      on_stderr = function(error, data)
        vim.print("error")
        vim.print(vim.inspect(error))
        vim.print(vim.inspect(data))
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
      on_stderr = function(error, data)
        vim.print(vim.inspect(error))
      end,
    })
    :sync()
end

local function new(prefix, tree_dir, callback)
  job
    :new({
      command = "forester",
      args = { "new", "--prefix", prefix, "--dir", tree_dir, "--dest", tree_dir },
      on_exit = function(data, _)
        vim.schedule(function()
          callback(data:result())
        end)
      end,
      on_stderr = function(error, data)
        vim.print(vim.inspect(error))
        vim.print(vim.inspect(data))
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
      on_stderr = function(error, data)
        vim.print(vim.inspect(error))
        vim.print(vim.inspect(data))
      end,
    })
    :sync()
end

Bindings.query = query
Bindings.new = new
Bindings.template = template
Bindings.complete = complete

return Bindings
