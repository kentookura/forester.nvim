local completionSource = require("forester.completion")
local commands = require("forester.commands")
local ui = require("forester.ui")
local config = require("forester.config")

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

local function setup()
  vim.filetype.add({ extension = { tree = "forester" } })

  local cfg = config.find_default_config()
  if cfg ~= "" then
    vim.g.forester_current_config = cfg
    vim.api.nvim_create_user_command("Forester", function(cmd)
      local prefix, _ = commands.parse(cmd.args)
      commands.cmd(prefix)
    end, {
      bar = true,
      bang = true,
      nargs = "?",
      complete = function(_, line)
        local prefix, args = commands.parse(line)
        if #args > 0 then
          return commands.complete(prefix, args[#args])
        end
        return vim.tbl_filter(function(key)
          return key:find(prefix, 1, true) == 1
        end, vim.tbl_keys(commands.commands))
      end,
    })
  end

  local cmp = require("cmp")

  cmp.register_source("forester", completionSource)
  cmp.setup.filetype("forester", { sources = { { name = "forester", dup = 0 } } })

  add_treesitter_config()

  -- Make links followable with `gf`

  local _ = pcall(function()
    local dirs = config.tree_dirs()
    for _, v in pairs(dirs) do
      vim.opt.path:append(v)
    end
  end)
  vim.opt.suffixesadd:prepend(".tree")
  ui.setup()
end

M.completionSource = completionSource
M.commands = commands
M.ui = ui
M.config = config
M.setup = setup

return M
