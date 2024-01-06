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
    dir = "./",
    config = function()
      local forester = require("forester")
      vim.g.mapleader = " "
      vim.keymap.set("n", "<leader>nn", forester.new_tree, { silent = true })
      vim.keymap.set("n", "<leader>nt", forester.new_from_template, { silent = true })
      vim.keymap.set("n", "<leader>n.", forester.open_tree, { silent = true })
      vim.keymap.set("n", "<leader>nh", forester.transclude_new, { silent = true })
      vim.keymap.set("n", "<leader>nl", forester.link_new, { silent = true })
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
