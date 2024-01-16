vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    dir = "./.", -- change this to line to: "kentookura/neovim",
    name = "forester.nvim",
    opts = {
      forests = { "~/glade/notes", "~/forest" }, -- global forest config
      tree_dirs = { "trees", "test/trees", "notes", "doc" }, -- plugin will check if current directory contains these
      conceal = true,
    },
    config = function(opts)
      local forester = require("forester").setup(opts)
      vim.keymap.set("n", "<leader>n.", "<cmd>Forester browse<CR>", { silent = true })
    end,
    dependencies = {
      { "nvim-telescope/telescope.nvim" },
      { "nvim-treesitter/nvim-treesitter" },
      { "nvim-lua/plenary.nvim" },
    },
  },
  { "nvim-treesitter/nvim-treesitter" },
})

vim.keymap.set("n", "<leader>t", "<Plug>PlenaryTestFile %")
vim.keymap.set("n", "<leader>r", "<Plug>Lazy reload forester.nvim")
