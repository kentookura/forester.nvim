local configs = require("lspconfig.configs")
local lspconfig = require("lspconfig")
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

parser_config.forester = {
  install_info = {
    url = "https://github.com/kentookura/tree-sitter-forester", -- local path or git repo
    files = { "src/parser.c" }, -- note that some parsers also require src/scanner.c or src/scanner.cc
    -- optional entries:
    branch = "main", -- default branch in case of git repo if different from master
    generate_requires_npm = false, -- if stand-alone parser without npm dependencies
    requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
  },
  filetype = "tree", -- if filetype does not match the parser name
}

vim.treesitter.language.register("tree", "forester")

configs.forester = {
  default_config = {
    cmd = {
      "dune",
      "exec",
      "forester-lsp",
    },
    filetypes = { "tree" },
    root_dir = lspconfig.util.root_pattern(".git"),
  },
}

require("forester").setup()
