local vim = vim

local function ensure_treesitter()
  vim.treesitter.language.register("tree", "forester")
  vim.filetype.add({ extension = { tree = "tree" } })

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

local function setup(opts)
  ensure_treesitter()

  vim.opt.path:append("trees")
  vim.opt.suffixesadd:prepend(".tree")

  vim.api.nvim_create_autocmd({ "BufNew", "BufEnter" }, {
    pattern = { "*.tree" },
    callback = function()
      vim.cmd(":TSBufEnable highlight")
      vim.cmd(":set conceallevel=2")
    end,
  })
end

setup()
