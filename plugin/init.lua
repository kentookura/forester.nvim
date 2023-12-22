local configs = require("lspconfig.configs")
local lspconfig = require("lspconfig")

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
