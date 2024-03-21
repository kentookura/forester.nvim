local CompletionSource = require("forester.completion")
local Commands = require("forester.commands")
local Ui = require("forester.ui")

local M = {}

local function add_treesitter_config()
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
  vim.treesitter.language.register("forester", "forester")
end

local function setup(config)
  vim.filetype.add({ extension = { tree = "forester" }, pattern = { ["*.tree"] = "forester" } })
  -- Ui.setup({ enable = true })
  if not config then
    config = { opts = { tree_dirs = { "trees" } } }
  end

  local opts = config.opts

  local cmp = require("cmp")

  cmp.register_source("forester", CompletionSource)
  cmp.setup({
    sources = { { name = "forester", dup = 0 } },
  })

  add_treesitter_config()

  -- Make links followable with `gf`
  for k, v in pairs(opts.tree_dirs) do
    vim.opt.path:append(v)
  end
  vim.opt.suffixesadd:prepend(".tree")

  vim.api.nvim_create_user_command("Forester", function(cmd)
    local prefix, args = Commands.parse(cmd.args)
    Commands.cmd(prefix, opts)
  end, {
    bar = true,
    bang = true,
    nargs = "?",
    complete = function(_, line)
      local prefix, args = Commands.parse(line)
      if #args > 0 then
        return Commands.complete(prefix, args[#args])
      end
      return vim.tbl_filter(function(key)
        return key:find(prefix, 1, true) == 1
      end, vim.tbl_keys(Commands.commands))
    end,
  })

  if opts.conceal then
    vim.cmd(":set conceallevel=2")
  end

  vim.api.nvim_create_autocmd({ "BufNew", "BufEnter" }, {
    pattern = { "*.tree" },
    callback = function(args)
      vim.treesitter.start(args.buf, "forester")
    end,
  })
  -- local hover = require("hover")
  -- hover.setup({})
  -- hover.register(Preview.hover_provider)
end

M.setup = setup

return M
