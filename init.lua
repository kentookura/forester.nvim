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
    opts = {
      tree_dirs = { "test/trees" },
      conceal = false,
    },
    config = function(opts)
      require("forester").setup(opts)
    end,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
      { "nvim-lua/plenary.nvim" },
    },
  },
})

vim.keymap.set("n", "<leader>t", "<Plug>PlenaryTestFile %")
