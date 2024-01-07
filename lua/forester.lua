local vim = vim
local api = vim.api
local ui = vim.ui
local cmd = vim.cmd
local forester = require("forester.bindings")
local job = require("plenary.job")
local forester_ns = api.nvim_create_namespace("forester.extmarks")
local M = {}

local tree_dir = "trees" -- Goal: unset this variable

local function ensure_treesitter()
  vim.treesitter.language.register("tree", "forester")
  vim.filetype.add({ extension = { tree = "tree" } })

  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
  parser_config.forester = {
    install_info = {
      url = "https://github.com/kentookura/forester.nvim",
      files = { "src/parser.c" },
      branch = "main",
      generate_requires_npm = false,
      requires_generate_from_grammar = false,
    },
    filetype = "tree",
  }
end

local setup = function(opts)
  vim.print(vim.inspect(opts.tree_dir)) -- Getting the option here, but not used
  ensure_treesitter()
  vim.opt.path:append(opts.tree_dir)
  vim.opt.suffixesadd:prepend(".tree")
  vim.api.nvim_create_autocmd({ "BufNew", "BufEnter" }, {
    pattern = { "*.tree" },
    callback = function()
      vim.cmd(":TSBufEnable highlight")
      vim.cmd(":set conceallevel=2")
    end,
  })
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

local function open_tree()
  local function select(data)
    ui.select(data, {
      prompt = "Select a tree title",
      format_item = function(item)
        -- local addr = item:match("[^, ]*$")
        -- local title = item:match("[^,]+$")
        return item
      end,
    }, function(choice)
      if choice == nil then
        return
      end
      local addr = choice:match("[^,%s]+")
      local path = vim.fn.findfile(addr .. ".tree", tree_dir .. "/**")
      vim.cmd("edit " .. path)
    end)
  end

  forester.complete(tree_dir, select)
end

local function on_enter()
  local lnum = api.nvim_win_get_cursor(0)[1]
  local start = { lnum - 1, 0 }
  local marks = api.nvim_buf_get_extmarks(0, forester_ns, start, start, {})
  if #marks > 0 then
    local mark_id = marks[1][1]
    local new_marks = {}
    for m, f in pairs(marks) do
      local mark = api.nvim_buf_get_extmark_by_id(0, forester_ns, m)
      local line = mark[1]
      local new_mark = api.nvim_buf_set_extmark(0, forester_ns, 0, line, 0, {})
      new_marks[new_mark] = f
    end
  end
end

local function split_path(path)
  -- Returns the Path, Filename, and Extension as 3 values
  return string.match(path, "^(.-)([^\\/]-)(%.[^\\/%.]-)%.?$")
end

--local function transclude_selection()
--  local function callback(data)
--    local path = data:result()[1]
--    local _, addr, _ = split_path(path)
--    local content = "\\transclude{" .. addr .. "}"
--
--    api.nvim_feedkeys("c", "v", false)
--    api.nvim_feedkeys(content, "i", false)
--    print(content)
--    --vim.cmd("edit " .. path)
--    --api.nvim_feedkeys("Go", "n", false)
--    --api.nvim_feedkeys(content, "i", false)
--  end
--
--  local function select_prefix()
--    return function(prefixes)
--      ui.select(
--        prefixes,
--        { prompt = "select a prefix" },
--        vim.schedule_wrap(function(prefix)
--          forester.new(prefix,config.tree_dir, callback)
--        end)
--      )
--    end
--  end
--  forester.query("prefix",config.tree_dir, select_prefix())
--end

--local transclusions = vim.treesitter.query.parse("tree", [[ (transclude (addr) @id) ]])

--local get_root = function(bufnr)
--  local parser = vim.treesitter.get_parser(bufnr, "tree", {})
--  local tree = parser:parse()[1]
--  return tree:root()
--end
--
--local virtualtext = function(bufnr)
--  bufnr = bufnr or api.nvim_get_current_buf()
--  if vim.bo[bufnr].filteype ~= "tree" then
--    vim.notify("can only be used for trees")
--  end
--  local root = get_root(bufnr)
--  local changes = {}
--  for id, node in transclusions:iter_captures(root, bufnr, 0, -1) do
--    local title = "foo"
--    local range = { node:range() }
--    print(vim.inspect(node))
--    --api.nvim_buf_set_virtual_text(bufnr, virtual_types_ns, start_line, msg)
--  end
--end
--
local function put(content)
  local r, c = api.nvim_win_get_cursor(0)
  api.nvim_buf_set_text(0, r, c, r, c, content)
end

local function link_new_tree()
  local function callback(data)
    local path = data:result()[1]
    local _, addr, _ = split_path(path)
    local content = "[](" .. addr .. ")"

    put(content)
    vim.cmd("write")
    vim.cmd("vsp " .. path)
    --api.nvim_feedkeys("Go", "n", false)
    --api.nvim_feedkeys(content, "i", false)
  end

  local function select(prefixes)
    ui.select(prefixes:result(), {}, function(prefix)
      --ui.select(prefixes:result(), {}, function(prefix)
      forester.new(prefix, tree_dir, callback)
    end)
  end

  forester.query("prefix", tree_dir, select)
end

local function link_tree()
  local function callback(data)
    local path = data:result()[1]
    local _, addr, _ = split_path(path)
    local content = "[](" .. addr .. ")"

    put(content)
    vim.cmd("write")
    vim.cmd("vsp " .. path)
    --api.nvim_feedkeys("Go", "n", false)
    --api.nvim_feedkeys(content, "i", false)
  end

  local function select(prefixes)
    ui.select(prefixes:result(), {}, function(prefix)
      --ui.select(prefixes:result(), {}, function(prefix)
      forester.new(prefix, tree_dir, callback)
    end)
  end

  forester.query("prefix", tree_dir, select)
end

local function transclude_tree()
  local function callback(data)
    local path = data:result()[1]
    local _, addr, _ = split_path(path)
    local content = "\\transclude{" .. addr .. "}"

    put(content)
    cmd("write")
    cmd("vsp " .. path)
    --api.nvim_feedkeys("Go", "n", false)
    --api.nvim_feedkeys(content, "i", false)
  end

  local function select(prefixes)
    ui.select(prefixes:result(), {}, function(prefix)
      --ui.select(prefixes:result(), {}, function(prefix)
      forester.new(prefix, tree_dir, callback)
    end)
  end

  local inspect = function(x)
    vim.print(vim.inspect(x))
  end
  forester.complete(tree_dir, inspect)
end

local function transclude_new_tree()
  local function callback(data)
    local path = data:result()[1]
    local _, addr, _ = split_path(path)
    local content = "\\transclude{" .. addr .. "}"

    put(content)
    cmd("write")
    cmd("vsp " .. path)
    --api.nvim_feedkeys("Go", "n", false)
    --api.nvim_feedkeys(content, "i", false)
  end

  local function select(prefixes)
    ui.select(prefixes:result(), {}, function(prefix)
      --ui.select(prefixes:result(), {}, function(prefix)
      forester.new(prefix, tree_dir, callback)
    end)
  end

  forester.query("prefix", tree_dir, select)
end

M.new_tree = new_tree
M.new_from_template = new_from_template
M.open_tree = open_tree
M.transclude_tree = transclude_tree
M.transclude_new_tree = transclude_new_tree
M.link_tree = link_tree
M.link_new_tree = link_new_tree
M.setup = setup

return M
