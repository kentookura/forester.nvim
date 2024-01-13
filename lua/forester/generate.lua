local vim = vim
local api = vim.api
local cmd = vim.cmd
local ui = vim.ui
local job = require("plenary.job")

local insert_at_cursor = require("forester.util").insert_at_cursor
local forester = require("forester.bindings")

local M = {}

local function new_from_template()
  local function select_prefix(template_addr)
    return function()
      ui.input(
        { prompt = "Enter a prefix: " },
        vim.schedule_wrap(function(prefix)
          forester.template(prefix, template_addr, tree_dir)
        end)
      )
    end
  end

  local function select_template(templates)
    ui.select(
      templates,
      { prompt = "select a template" },
      vim.schedule_wrap(function(template)
        if template == nil then
          return
        end
        local tmpl_addr = template:match("^([^.]+)")
        forester.query("prefix", tree_dir, select_prefix(tmpl_addr))
      end)
    )
  end

  job
    :new({
      command = "ls",
      args = { "templates" },
      on_exit = vim.schedule_wrap(function(j, _)
        select_template(j:result())
      end),
    })
    :sync()
end

local function new_tree()
  local function edit_callback(new_addr)
    cmd("edit " .. new_addr[1])
  end

  ui.input({ prompt = "Enter a prefix: " }, function(prefix)
    if prefix == nil then
      return
    end
    forester.new(prefix, tree_dir, edit_callback)
  end)
end

local function transclude_new_tree()
  local function callback(data)
    local path = data:result()[1]
    local _, addr, _ = split_path(path)
    local content = { "\\transclude{" .. addr .. "}" }
    insert_at_cursor(content)
  end
  local function select(prefixes)
    ui.select(prefixes:result(), {}, function(prefix) -- TODO use completion, not ui.select
      forester.new(prefix, tree_dir, callback)
    end)
  end

  forester.query("prefix", tree_dir, select)
end

local function link_new_tree()
  local function callback(data)
    local path = data[1]
    local _, addr, _ = split_path(path)
    local content = { "[](" .. addr .. ")" }
    insert_at_cursor(content)
  end

  local function select(prefixes)
    ui.select(prefixes:result(), {}, function(prefix) -- TODO use completion, not ui.select
      forester.new(prefix, tree_dir, callback)
    end)
  end

  forester.query("prefix", tree_dir, select)
end

M.new_from_template = new_from_template
M.new_tree = new_tree
M.transclude_new_tree = transclude_new_tree

return M
