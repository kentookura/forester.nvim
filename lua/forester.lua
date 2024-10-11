--- *forester.nvim* Forester filetype plugin
---
--- =========================================================================
---
--- Supported features:
--- - Autocomplete
--- - following links via `gf`
--- - fuzzy finding
---
--- # Setup ~
---
--- Initialize the plugin via `require("forester").setup()`
---
--- In your `forest.toml`, add the list of prefixes you wish to use:
--- >toml
--- prefixes = ["foo", "bar"]
--- <
--- This plugin currently does not support user configuration via lua.
--- I think it is preferrable to use the forester configuration files and
--- extracting the relevant keys via treesitter
---

local completionSource = require("forester.completion")
local commands = require("forester.commands")
local ui = require("forester.ui")
local config = require("forester.config")

local M = {}

local function register_treesitter_parser()
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
  local forester_group = vim.api.nvim_create_augroup("ForesterGroup", { clear = true })

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

  -- Make links followable with `gf`
  local add_treedirs_to_path = function()
    pcall(function()
      local dirs = config.tree_dirs()
      for _, v in pairs(dirs) do
        vim.opt.path:append(v)
      end
    end)
  end

  vim.api.nvim_create_autocmd("User", {
    group = forester_group,
    pattern = "SwitchedForesterConfig",
    callback = function()
      add_treedirs_to_path()
    end,
  })

  local cmp = require("cmp")

  cmp.register_source("forester", completionSource)
  cmp.setup.filetype("forester", { sources = { { name = "forester", dup = 0 } } })

  register_treesitter_parser()

  vim.opt.suffixesadd:prepend(".tree")

  add_treedirs_to_path()
  ui.setup()
end

M.completionSource = completionSource
M.commands = commands
M.ui = ui
M.config = config
M.setup = setup

return M
