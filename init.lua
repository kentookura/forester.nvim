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
    dir = "./.", -- change this to line to "kentookura/neovim"
    tree_dir = "notes",
    config = function(opts)
      local forester = require("forester")
      forester.setup(opts)
      vim.print(vim.inspect(forester))
      --vim.g.mapleader = " "
      --vim.keymap.set("n", "<leader>n.", forester.open_tree, { silent = true })
      --vim.keymap.set("n", "<leader>nn", forester.new_tree, { silent = true })
      --vim.keymap.set("n", "<leader>ng", forester.new_from_template, { silent = true }) --"generate"
    end,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/playground" },
      --{ "ziontee113/SelectEase" },
      --{ "nvim-telescope/telescope.nvim" },
    },
  },
})
