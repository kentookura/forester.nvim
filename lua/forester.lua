local vim = vim
local api = vim.api
local cmd = vim.cmd
local forester = require("forester.bindings")
local util = require("forester.util")
local job = require("plenary.job")

local split_path = util.split_path

local M = {}

local function ensure_treesitter()
  vim.treesitter.language.register("tree", "forester")
  vim.filetype.add({ extension = { tree = "tree" } })

  require("nvim-treesitter.configs").setup({ ensure_installed = { "forester" } })
  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
  parser_config.forester = {
    install_info = {
      url = "https://github.com/kentookura/tree-sitter-forester",
      files = { "src/parser.c" },
      branch = "main",
      generate_requires_npm = false,
      requires_generate_from_grammar = false,
    },
    filetype = "tree",
  }
end

local function setup(config)
  if not config then
    config = {}
  end
  ensure_treesitter()
  vim.opt.path:append("trees")
  vim.opt.suffixesadd:prepend(".tree")

  vim.print("setting up")
  vim.api.nvim_create_autocmd({ "BufNew", "BufEnter" }, {
    pattern = { "*.tree" },
    callback = function(args)
      vim.treesitter.start(args.buf, "forester")
      --vim.print("opened a tree file")
      --vim.cmd(":set filetype=tree")
      --vim.cmd(":set conceallevel=2")
    end,
  })
end

local function endswith(string, suffix)
  return string:sub(-#suffix) == suffix
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
  forester.complete(tree_dir, inspect) -- TODO
end

M.list_trees = list_trees
M.transclude_tree = transclude_tree
M.link_tree = link_tree
M.setup = setup

return M
