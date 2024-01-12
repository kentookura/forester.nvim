local vim = vim
local api = vim.api
local ui = vim.ui
local cmd = vim.cmd
local forester = require("forester.bindings")
local util = require("forester.util")
local job = require("plenary.job")
<<<<<<< HEAD
local forester_ns = api.nvim_create_namespace("forester.extmarks")
=======

local split_path = util.split_path
local to_addr = util.to_addr

>>>>>>> 47560e0 (refactor)
local M = {}

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

local tree_dir = "trees" -- Goal: unset this variable

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

local function endswith(string, suffix)
  return string:sub(-#suffix) == suffix
end

function map(iterable, f)
  local new = {}
  for i, v in pairs(iterable) do
    new[i] = f(v)
  end
  return new
end
function filter(iterable, pred)
  local new = {}
  for i, v in ipairs(iterable) do
    if pred(v) then
      table.insert(new, v)
    end
  end
  return new
end

function fold(iterable, alg)
  if #iterable == 0 then
    return nil
  end
  local out = nil
  for i = 1, #iterable do
    out = alg(out, iterable[i])
  end
  return out
end

local function list_trees(dir, callback)
  local f = function(file)
    return endswith(file, ".tree")
  end
  job
    :new({
      command = "ls",
      args = { dir },
      on_exit = vim.schedule_wrap(function(j, exitcode)
        local trees = filter(j:result(), f)
        --vim.print(vim.inspect(j:result()))
        callback(trees)
        -- vim.print(vim.inspect(trees))
      end),
      on_stderr = vim.schedule_wrap(function(j, data)
        vim.print(vim.inspect(data))
      end),
    })
    :sync()
end

local pad_addr = function(i)
  local base36_str = util.encode(i)
  local required_padding = 4 - #tostring(base36_str)
  if required_padding < 0 then
    return base36_str
  else
    return string.rep("0", required_padding) .. base36_str
  end
end

local function next_addr()
  local function inc_addr(prefix, tree_num) -- TODO bind these to <C-x> and <C-a>
    local next = prefix .. "-" .. pad_addr(tree_num + 1)
    print("inc")
    -- todo: query addr, replace, see tjs video
  end
end

local function prev_addr()
  local function decr_addr(prefix, tree_num)
    local prev = prefix .. "-" .. pad_addr(tree_num - 1)
    print("decr")
    -- todo: query addr, replace, see tjs video
  end
end

local function new_tree()
<<<<<<< HEAD
  local function edit_callback(new_addr)
    cmd("edit " .. new_addr[1])
=======
  local function edit_callback(res)
<<<<<<< HEAD
    cmd("edit " .. res:result()[1])
>>>>>>> 31d6429 (add transclude_new and link_new)
=======
    cmd("edit " .. res)
>>>>>>> 47560e0 (refactor)
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

local scratch = function()

  --vim.lsp.buf_request(0, 'forester-lsp/inlayHints', {params_go_here}, function(_,_, results) print(vim.inspect(results)))
end

local draw_title_inlay = function(bufnr, pos, title)
  local r = pos[1]
  local c = pos[2]
  api.nvim_buf_set_extmark(bufnr, forester_ns, r, c, { virt_text = { { title, "@comment" } }, virt_text_pos = "eol" })
end

--api.nvim_buf_clear_namespace(0, forester_ns, 0, -1)

--draw_title_inlay(0, { 173, 0 }, "hello")

local draw_inline_hints = function(bufnr)
  local get_tree_root = function()
    local parser = vim.treesitter.get_parser(0)
    local tree = parser:parse()[1]
    vim.print(vim.inspect(tree:root()))
  end

  local addrs = vim.treesitter.query.parse("forester", [[(addr) @addr]])

  local query_title = function(addr)
    return "TODO"
  end

  local marks = {}
  for id, node in addrs:iter_captures(root, bufnr, 0, -1) do
    local name = addrs.captures[id]
    -- {start row, start col, end row, end col}
    local range = { node:range() }

    table.insert(changes, 1, {
      start = range[1],
      final = range[3],
      title = query_title(id),
    })
    for _, mark in ipairs(marks) do
      draw_title_inlay(bufnr, { mark.start, mark.final }, mark.title)
    end
  end
end

local function insert_at_cursor(content)
  local pos = api.nvim_win_get_cursor(0)
  local r = pos[1]
  local c = pos[2]
  api.nvim_buf_set_text(0, r - 1, c, r - 1, c, content)
end

<<<<<<< HEAD
local function link_new_tree()
  local function callback(data)
    local path = data:result()[1]
=======
local function link_new()
  local function callback(path)
<<<<<<< HEAD
>>>>>>> 31d6429 (add transclude_new and link_new)
    local _, addr, _ = split_path(path)
    local content = { "[](" .. addr .. ")" }
=======
    local content = { "[](" .. to_addr(path) .. ")" }
>>>>>>> 47560e0 (refactor)
    insert_at_cursor(content)
  end

  local function select(prefixes)
    ui.select(prefixes:result(), {}, function(prefix) -- TODO use completion, not ui.select
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

local function setup(opts)
  vim.print(opts)
  vim.api.nvim_create_autocmd({ "BufNew", "BufEnter" }, {
    pattern = { "*.tree" },
    callback = function(args)
      draw_inline_hints(args.buf)
    end,
  })
end

M.list_trees = list_trees
M.new_tree = new_tree
M.new_from_template = new_from_template
M.open_tree = open_tree
M.transclude_tree = transclude_tree
M.transclude_new_tree = transclude_new_tree
M.link_tree = link_tree
M.link_new_tree = link_new_tree
M.setup = setup
M.pad_addr = pad_addr
M.link_new = link_new
M.prev_addr = prev_addr
M.next_addr = next_addr
M.setup = setup

return M
