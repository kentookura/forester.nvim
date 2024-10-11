local pickers = require("forester.pickers")
local Scan = require("plenary.scandir")
local Path = require("plenary.path")
local util = require("forester.util")

local M = {}

local function all_configs()
  return Scan.scan_dir(".", { search_pattern = "toml" })
end

--local function find_config(filename)
--  return vim.fn.findfile(filename, ".;") -- .; searches up. :h file-searching for more info
--end

M.find_default_config = function()
  return vim.fn.findfile("forest.toml", ".;")
end

local function get_file_contents(filename)
  return table.concat(vim.fn.readfile(filename), "\n")
end

local tree_dirs = function()
  local config = vim.g.forester_current_config
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

-- NOTE: This function computes the `dest_dir` argument of `forester new`
-- Check each configured tree directory for trees matching the prefix,
-- get the highest id in each tree and return the directory containing the
-- maximum id.
--
M.dir_of_latest_tree_of_prefix = function(pfx)
  local dirs = tree_dirs()
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

local function all_prefixes()
  local config = vim.g.forester_current_config
  local text = table.concat(vim.fn.readfile(config), "\n")
  local parser = vim.treesitter.get_string_parser(text, "toml")

  local query = vim.treesitter.query.parse(
    "toml",
    [[(document
        (table
          (pair
            (bare_key) @key (#eq? @key "prefixes")
            (array (string) @prefix))))
    ]]
  )

  local pfxs = {}
  for id, node in query:iter_captures(parser:parse()[1]:root(), text) do
    local name = query.captures[id]
    if name == "prefix" then
      local pfx = vim.treesitter.get_node_text(node, text):gsub('^"(.*)"$', "%1")
      local str = pfx:gsub('^"(.*)"$', "%1")
      table.insert(pfxs, str)
    end
  end
  return pfxs
end

local function switch()
  local configs = all_configs()
  pickers.pick_config(configs)
  vim.api.nvim_exec_autocmds("User", { pattern = "SwitchedForesterConfig" })
end

M.all_prefixes = all_prefixes
M.tree_dirs = tree_dirs
M.switch_config = switch

return M
