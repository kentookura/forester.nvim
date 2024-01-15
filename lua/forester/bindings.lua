---@tag forester.bindings

---@brief [[
---
--- Bindings to the forester command for internal use
---
---]]

local vim = vim
local util = require("forester.util")
local Job = require("plenary.job")

local Bindings = {}

local function titles(tree_dir) -- TODO: submit patch to forester for querying paths
  local job = Job:new({
    command = "forester",
    args = { "complete", tree_dir },
    enable_recording = true,
  })
  job:sync()
  --local result = job:result()
  local out = {}
  local result = util.map(job:result(), function(r)
    local addr, title = r:match("([^,]+), ([^,]+)")
    return { addr = addr, title = title }
  end)
  for k, v in pairs(result) do
    out[k] = { addr = v.addr, title = v.title, dir = tree_dir }
  end
  return out
end

--vim.print(vim.inspect(titles("test/trees")))

local function query(arg, tree_dir)
  local res = Job:new({
    command = "forester",
    args = { "query", arg, tree_dir },
  }):sync()
  return res
end

local function new(prefix, tree_dir)
  local job = Job:new({
    command = "forester",
    args = {
      "new",
      "--prefix",
      prefix,
      "--dir",
      tree_dir,
      "--dest",
      tree_dir,
    },
    on_stderr = function(i, j)
      vim.print("err")
      --for k in j do
      --vim.print(vim.inspect(j))
      --end
    end,
    on_stdout = function(i, j)
      vim.print("stdout")
      --vim.print(j)
    end,
    --on_exit = function(i, j)
    --  --vim.print("exit")
    --  -vim.print(j)
    --end,
  })
  job:sync()
  return job:result()
end

local function template(pfx, tmpl_addr, tree_dir)
  Job:new({
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
        vim.cmd("edit " .. res:result()[1])
      end)
    end),
    on_stderr = function(error, data)
      vim.print(vim.inspect(error))
      vim.print(vim.inspect(data))
    end,
  }):sync()
end

Bindings.query = query
Bindings.new = new
Bindings.template = template
Bindings.titles = titles

return Bindings
