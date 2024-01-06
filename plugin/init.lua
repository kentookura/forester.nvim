local vim = vim

local function ensure_treesitter()
  vim.treesitter.language.register("tree", "forester")
  vim.filetype.add({ extension = { tree = "tree" } })

  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
  parser_config.forester = {
    install_info = {
      --url = "https://github.com/kentookura/tree-sitter-forester", -- local path or git repo
      url = "/home/kento/glade/tree-sitter-forester/", -- local path or git repo
      files = { "src/parser.c" }, -- note that some parsers also require src/scanner.c or src/scanner.cc
      -- optional entries:
      branch = "main", -- default branch in case of git repo if different from master
      generate_requires_npm = false, -- if stand-alone parser without npm dependencies
      requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
    },
    filetype = "tree", -- if filetype does not match the parser name
  }
end

local function setup(opts)
  ensure_treesitter()

  vim.opt.path:append("trees") -- [TODO] specify tree directory
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
