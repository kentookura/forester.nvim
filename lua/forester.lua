local api = vim.api
local CompletionSource = require("forester.completion")
local Commands = require("forester.commands")
local Forester = require("forester.bindings")
local util = require("forester.util")
local job = require("plenary.job")

local forester_ns = api.nvim_create_namespace("forester.extmarks")

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
    config = { opts = { tree_dirs = "trees" } }
  end

  require("cmp").register_source("forester", CompletionSource)
  require("cmp").setup({
    sources = { { name = "forester" } },
  })

  local opts = config.opts
  ensure_treesitter()
  vim.opt.path:append("trees")
  vim.opt.suffixesadd:prepend(".tree")

  vim.api.nvim_create_user_command("Forester", function(cmd)
    local prefix, args = Commands.parse(cmd.args)
    --if #args == 1 and args[1] == "all" then
    --  args = vim.tbl_keys(Config.plugins)
    --end
    --if #args > 0 then
    --  opts.plugins = vim.tbl_map(function(plugin)
    --    return Config.plugins[plugin]
    --  end, args)
    --end
    Commands.cmd(prefix, opts)
  end, {
    bar = true,
    bang = true,
    nargs = "?",
    complete = function(_, line)
      local prefix, args = Commands.parse(line)
      if #args > 0 then
        return M.complete(prefix, args[#args])
      end
      return vim.tbl_filter(function(key)
        return key:find(prefix, 1, true) == 1
      end, vim.tbl_keys(Commands.commands))
    end,
  })

  vim.api.nvim_create_autocmd({ "BufNew", "BufEnter" }, {
    pattern = { "*.tree" },
    callback = function(args)
      vim.treesitter.start(args.buf, "forester")
      if opts.conceal then
        vim.cmd(":set conceallevel=2")
      end
    end,
  })
end

local function endswith(string, suffix)
  return string:sub(-#suffix) == suffix
end

local function select_title(titles, callback)
  vim.ui.select(titles, {
    format_item = function(item)
      return item.title .. " (" .. item.addr .. ")"
    end,
  }, callback)
end

local function link_tree(tree_dir)
  local titles = Forester.titles(tree_dir)
  select_title(titles, function(choice)
    util.insert_at_cursor({ "[](" .. choice.addr .. ")" })
  end)
end

local function transclude_tree(tree_dir)
  local titles = Forester.titles(tree_dir)
  select_title(titles, function(choice)
    util.insert_at_cursor({ "\\transclude{" .. choice.addr .. "}" })
  end)
end

--M.transclude_tree = transclude_tree
--M.link_tree = link_tree
M.setup = setup

return M
