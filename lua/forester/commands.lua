local util = require("forester.util")
local Forester = require("forester.bindings")
local Job = require("plenary.job")
local config = require("forester.config")
local pickers = require("forester.pickers")
local M = {}

local select = function(items, callback)
  if #items == 1 then
    do
      callback(items[1])
    end
  else
    do
      vim.ui.select(items, {}, function(choice)
        if choice == nil then
          do
            return
          end
        else
          do
            callback(choice)
          end
        end
      end)
    end
  end
end

local select_prefix = function(callback)
  if vim.g.forester_current_config.prefixes == nil then
    do
      vim.notify(
        "Prefixes are not configured in "
          .. vim.g.forester_current_config["path"]
          .. '. Add them like this: \nprefixes = ["foo"]'
      )
    end
  else
    select(vim.g.forester_current_config.prefixes, callback)
  end
end

M.commands = {
  -- Select the forester configuration file to use
  config = function()
    local configs = config.all_configs()
    if #configs == 0 then
      vim.notify("No forester configs available in the current directory!", vim.log.levels.WARN)
    else
      pickers.pick_config(configs)
      vim.api.nvim_exec_autocmds("User", { pattern = "SwitchedForesterConfig" })
    end
    -- config.switch()
  end,

  build = function()
    local job = Job:new({ command = "forester", args = { "build", vim.g.forester_current_config } })
    job:and_then_on_success(vim.notify("Successfully built the forest"))
  end,

  browse = function()
    local trees = Forester.query_all(vim.g.forester_current_config.path)
    local t = {}
    for k, v in pairs(trees) do
      v.addr = k
      table.insert(t, v)
    end
    if #t == 0 then
      do
        vim.print("No trees found!")
      end
    end
    pickers.pick_by_title(t, {})
  end,

  new_random = function()
    select_prefix(function(choice)
      local path = config.dir_of_latest_tree_of_prefix(choice)
      local new_tree = Forester.new_random(choice, path, vim.g.forester_current_config)[1]
      vim.cmd("edit " .. new_tree)
    end)
  end,

  new = function()
    select_prefix(function(choice)
      do
        local path = config.dir_of_latest_tree_of_prefix(choice)
        local new_tree = Forester.new(choice, path, vim.g.forester_current_config)[1]
        vim.cmd("edit " .. new_tree)
      end
    end)
  end,

  transclude_new = function()
    select(vim.g.forester_current_config.prefixes, function(choice)
      do
        local path = config.dir_of_latest_tree_of_prefix(choice)
        local new_tree = Forester.new(choice, path, vim.g.forester_current_config)[1]
        local addr = util.filename(new_tree):match("(.+)%..+$")
        local content = { "\\transclude{" .. addr .. "}" }
        vim.api.nvim_put(content, "c", true, true)
      end
    end)
  end,

  link_new = function()
    select(vim.g.forester_current_config.prefixes, function(choice)
      local path = config.dir_of_latest_tree_of_prefix(choice)
      local new_tree = Forester.new(choice, path)[1]
      local addr = util.filename(new_tree):match("(.+)%..+$")
      local content = { "[](" .. addr .. ")" } --  NOTE: We should improve the workflow with snippets or something similar
      vim.api.nvim_put(content, "c", true, true)
    end)
  end,
}

function M.parse(args)
  local parts = vim.split(vim.trim(args), "%s+")
  if parts[1]:find("Forester") then
    table.remove(parts, 1)
  end

  if args:sub(-1) == " " then
    parts[#parts + 1] = ""
  end
  return table.remove(parts, 1) or "", parts
end

function M.cmd(cmd)
  local command = M.commands[cmd]
  if command == nil then
    vim.print("Invalid forester command '" .. cmd .. "'")
  elseif cmd == "config" then
    command()
  else
    local current_cfg = vim.g.forester_current_config
    if current_cfg == "" or current_cfg == vim.NIL or current_cfg == nil then
      vim.notify("No forester config file is set! Use `:Forester config` to select one", vim.log.levels.WARN)
    elseif vim.fn.executable("forester") ~= 1 then
      vim.notify("The `forester` command is not available!", vim.log.levels.WARN)
    else
      command()
    end
  end
end

return M
