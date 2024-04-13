---@tag forester.bindings

---@brief [[
---
--- Bindings to the forester program.
---
---]]

local util = require("forester.util")
local Job = require("plenary.job")

local Bindings = {}

local function find_config(filename)
  return vim.fn.findfile(filename, ".;")
end

local function find_default_config()
  return vim.fn.findfile("forest.toml", ".;")
end

local function get_file_contents(filename)
  return table.concat(vim.fn.readfile(filename), "\n")
end

local get_tree_dirs = function(config)
  local text = get_file_contents(config)
  local parser = vim.treesitter.get_string_parser(text, "toml")

  local query = vim.treesitter.query.parse(
    "toml",
    [[(document
        (table
          (pair
            (bare_key) @key (#eq? @key "trees")
            (array (string) @dir))))
    ]]
    -- (bare_key) @key (#eq? @key "trees")
    -- (array (string) @tree_dir ))))
  )

  local dirs = {}
  for id, node in query:iter_captures(parser:parse()[1]:root(), text) do
    local name = query.captures[id]
    if name == "dir" then
      local dir = vim.treesitter.get_node_text(node, text)
      local str = dir:gsub('^"(.*)"$', "%1")
      table.insert(dirs, str)
    end
  end
  return dirs
end

vim.print(vim.inspect(get_tree_dirs(find_default_config())))

local function watch(tree_dir, port)
  local _port = port or 1234
  return Job:new({ command = "forest", args = { "watch", _port, tree_dir } })
end

local function build()
  local job = Job:new({ command = "forester", args = { "build" } })
  job:sync()
  return job:result()
end

local function titles()
  local job = Job:new({
    command = "forester",
    args = { "complete" },
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

local function query(arg)
  local res = Job:new({
    command = "forester",
    args = { "query", arg },
  }):sync()
  return res
end

local function query_all()
  local res = Job:new({
    command = "forester",
    args = { "query", "all" },
  }):sync()
  return vim.json.decode(res[1])
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
  })
  job:sync()
  return job:result()
end

-- where should the dest come from?
local function template(pfx, tmpl_addr, dest)
  Job:new({
    command = "forester",
    args = {
      "new",
      "--prefix",
      pfx,
      -- "--dir",
      -- tree_dir,
      "--dest",
      dest("--template"),
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

Bindings.watch = watch
Bindings.build = build
Bindings.query = query
Bindings.query_all = query_all
Bindings.new = new
Bindings.template = template
Bindings.titles = titles

return Bindings
