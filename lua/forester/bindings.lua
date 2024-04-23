---@tag forester.bindings

---@brief [[
---
--- Bindings to the forester program.
---
---]]

local util = require("forester.util")
local Job = require("plenary.job")
local Path = require("plenary.path")
local Scan = require("plenary.scandir")

local Bindings = {}

local os_sep = Path.path.sep

local function find_config(filename)
  return vim.fn.findfile(filename, ".;")
end

local function find_default_config()
  return vim.fn.findfile("forest.toml", ".;")
end

local function get_file_contents(filename)
  return table.concat(vim.fn.readfile(filename), "\n")
end

local tree_dirs = function(config)
  local text = get_file_contents(config)
  local parser = vim.treesitter.get_string_parser(text, "toml")
  local root_dir = Path:new(config):parents()[1]

  local query = vim.treesitter.query.parse(
    "toml",
    [[(document
        (table
          (pair
            (bare_key) @key (#eq? @key "trees")
            (array (string) @dir))))
    ]]
  )

  local dirs = {}
  for id, node in query:iter_captures(parser:parse()[1]:root(), text) do
    local name = query.captures[id]
    if name == "dir" then
      local dir = vim.treesitter.get_node_text(node, text)
      local str = dir:gsub('^"(.*)"$', "%1")
      table.insert(dirs, root_dir .. "/" .. str)
    end
  end
  return dirs
end

local dir_of_latest_tree_of_prefix = function(cfg, pfx)
  local config = find_config(cfg)
  local dirs = tree_dirs(config)
  if #dirs == 1 then
    return dirs[1]
  else
    local highest_in_each_dir = util.map(dirs, function(dir)
      local dir_and_file = util.map(Scan.scan_dir(dir), function(file)
        local split_path = vim.split(file, os_sep)
        local fname = split_path[#split_path]
        return { dir, fname }
      end)
      local matching_pfx = util.filter(dir_and_file, function(f)
        return string.sub(f[2], 1, string.len(pfx)) == pfx
      end)
      local ids = util.map(matching_pfx, function(f)
        local pattern = "%-([^%.]+)%.%w+$"
        local id = string.match(f[2], pattern)
        return { f[1], util.decode(id) }
      end)
      return ids
    end)
    local output = {}
    for _, tbl in ipairs(highest_in_each_dir) do
      for k, v in ipairs(tbl) do
        output[k] = v[1]
      end
    end
    return output[#output]
  end
end

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
Bindings.dir_of_latest_tree_of_prefix = dir_of_latest_tree_of_prefix
Bindings.tree_dirs = tree_dirs

return Bindings
