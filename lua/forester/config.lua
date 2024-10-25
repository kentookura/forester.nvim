local Scan = require("plenary.scandir")
local util = require("forester.util")

local M = {}

local function all_configs()
  return Scan.scan_dir(".", { search_pattern = "toml" })
end

local function find_default_config()
  return vim.fn.findfile("forest.toml", ".;")
end

---@param filename string
local function parse(filename)
  local content = table.concat(vim.fn.readfile(filename), "\n")
  local parser = vim.treesitter.get_string_parser(content, "toml")

  local tree_dir_query = vim.treesitter.query.parse(
    "toml",
    [[
  (document
    (table
      (pair
        (bare_key) @key (#eq? @key "trees")
        (array (string) @trees))))
  ]]
  )

  local prefix_query = vim.treesitter.query.parse(
    "toml",
    [[
  (document
    (table
      (pair
        (bare_key) @key (#eq? @key "prefixes")
        (array (string) @prefixes))))
      ]]
  )

  local assets_query = vim.treesitter.query.parse(
    "toml",
    [[
  (document
    (table
      (pair
        (bare_key) @key (#eq? @key "assets")
        (array (string) @assets))))
              ]]
  )
  local home_query = vim.treesitter.query.parse(
    "toml",
    [[
  (document
    (table
      (pair
        (bare_key) @key (#eq? @key "home")
        (string) @home)))
  ]]
  )
  local base_url_query = vim.treesitter.query.parse(
    "toml",
    [[
  (document
    (table
      (pair
        (bare_key) @key (#eq? @key "base_url")
        (string) @base_url)))
        ]]
  )

  local theme_query = vim.treesitter.query.parse(
    "toml",
    [[
  (document
    (table
      (pair
        (bare_key) @key (#eq? @key "theme")
        (string) @theme)))
        ]]
  )

  local queries = { tree_dir_query, prefix_query, assets_query, home_query, base_url_query, theme_query }

  local config = {}
  for _, query in pairs(queries) do
    for id, node in query:iter_captures(parser:parse()[1]:root(), content) do
      local name = query.captures[id]
      if name ~= "key" then
        local v = vim.treesitter.get_node_text(node, content)

        local str = v:gsub('^"(.*)"$', "%1")
        if config[name] == nil then
          config[name] = { str }
        else
          table.insert(config[name], str)
        end
      end
    end
  end
  config["path"] = filename
  return config
end

local function set_default_config()
  local f = find_default_config()
  if f == "" then
    return
  else
    local parsed = parse(f)
    vim.g.forester_current_config = parsed
  end
end

-- NOTE: This function computes the `dest_dir` argument of `forester new`
-- Check each configured tree directory for trees matching the prefix,
-- get the highest id in each tree and return the directory containing the
-- maximum id.
--
M.dir_of_latest_tree_of_prefix = function(pfx)
  local dirs = vim.g.forester_current_config.trees
  if #dirs == 1 then
    return dirs[1]
  else
    local tmp = util.filter_map(dirs, function(dir)
      local highest = util.highest_in_dir(pfx, dir)
      if highest == nil then
        return { false }
      else
        return { true, highest }
      end
    end)
    local res = {}
    for _, v in pairs(tmp) do
      res[v[2]] = v[1]
    end
    return res[table.maxn(res)]
  end
end

M.parse = parse
M.set_default_config = set_default_config
M.all_configs = all_configs

return M
