---@tag forester.bindings

---@brief [[
---
--- Bindings to the forester program.
---
---]]

local util = require("forester.util")
local Job = require("plenary.job")

local bindings = {}

local function init(dir)
  local d_arg
  if dir then
    d_arg = { "--dir", dir }
  else
    d_arg = {}
  end
  return Job:new({ command = "forester", args = { "init", table.unpack(d_arg) } })
end

local function watch(tree_dir, port)
  local _port = port or 1234
  return Job:new({ command = "forest", args = { "watch", _port, tree_dir } })
end

local function build(config, opts)
  opts = opts or {}
  local args = { "build" }
  if opts.no_assets ~= nil and opts.no_assets then
    table.insert(args, "--no-assets=true")
  end
  if opts.no_theme ~= nil and opts.no_theme then
    table.insert(args, "--no-theme=true")
  end
  if opts.render_only ~= nil then
    table.insert(args, "--render-only=" .. opts.render_only)
  end
  table.insert(args, config)
  local job = Job:new({ command = "forester", args = args })
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
  local result = util.filter_map(job:result(), function(r)
    local addr, title = r:match("([^,]+), ([^,]+)")
    if addr == nil or title == nil then
      return { false }
    else
      return { true, { addr = addr, title = title } }
    end
  end)
  for _, v in pairs(result) do
    out[v.addr] = v.title
    -- { addr = v.addr, title = v.title }
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
  if res ~= nil then
    return vim.json.decode(res[1])
  end
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

local function new_random(prefix, tree_dir, config)
  local job = Job:new({
    command = "forester",
    args = {
      "new",
      "--prefix",
      prefix,
      "--dest",
      tree_dir,
      "--random",
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

bindings.watch = watch
bindings.init = init
bindings.build = build
bindings.query = query
bindings.query_all = query_all
bindings.new = new
bindings.new_random = new_random
bindings.template = template
bindings.titles = titles

return bindings
