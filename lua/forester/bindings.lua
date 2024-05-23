---@tag forester.bindings

---@brief [[
---
--- Bindings to the forester program.
---
---]]

local util = require("forester.util")
local Job = require("plenary.job")

--local Path = require("plenary.path")

local Bindings = {}

local function watch(tree_dir, port)
  local _port = port or 1234
  return Job:new({ command = "forest", args = { "watch", _port, tree_dir } })
end

local function build(config)
  local job = Job:new({ command = "forester", args = { "build", config } })
  job:sync()
  return job:result()
end

local function titles(config)
  local job = Job:new({
    command = "forester",
    args = { "complete", config },
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
    out[k] = { addr = v.addr, title = v.title }
  end
  return out
end

local function query(arg, config)
  local res = Job:new({
    command = "forester",
    args = { "query", arg, config },
  }):sync()
  return res
end

local function query_all(config)
  local res = Job:new({
    command = "forester",
    args = { "query", "all", config },
  }):sync()
  return vim.json.decode(res[1])
end

local function new(prefix, tree_dir, config)
  local job = Job:new({
    command = "forester",
    args = {
      "new",
      "--prefix",
      prefix,
      "--dest",
      tree_dir,
      config,
    },
  })
  job:sync()
  return job:result()
end

-- where should the dest come from?
local function template(pfx, tmpl_addr, dest, config)
  Job:new({
    command = "forester",
    args = {
      "new",
      "--prefix",
      pfx,
      "--dest",
      dest("--template"),
      tmpl_addr,
      config,
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

Bindings.watch = watch
Bindings.build = build
Bindings.query = query
Bindings.query_all = query_all
Bindings.new = new
Bindings.template = template
Bindings.titles = titles

return Bindings
