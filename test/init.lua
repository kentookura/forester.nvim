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
      -- forests = { "~/glade/notes", "~/forest" }, -- global forest config
      tree_dirs = { "trees" }, -- plugin will check if current directory contains these
      preview = { port = "1234" },
      conceal = true,
    },
    config = function(opts)
      local forester = require("forester").setup(opts)

      -- vim.keymap.set("n", "<leader>k", require("hover").hover, { desc = "hover.nvim" })
      vim.keymap.set("n", "<leader>n.", "<cmd>Forester browse<CR>", { silent = true })
      vim.keymap.set("n", "<leader>nn", "<cmd>Forester new<CR>", { silent = true })
      -- vim.keymap.set("i", "<C-t>", "<cmd>Forester transclude<CR>", { silent = true })
      -- vim.keymap.set("i", "<C-l>", "<cmd>Forester link<CR>", { silent = true })
    end,
    dependencies = {
      { "nvim-telescope/telescope.nvim" },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      { "nvim-treesitter/nvim-treesitter" },
      { "nvim-lua/plenary.nvim" },
      { "hrsh7th/nvim-cmp" },
      { "MunifTanjim/nui.nvim" },
      -- { "lewis6991/hover.nvim" },
    },
  },
  { "nvim-treesitter/nvim-treesitter" },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  {
    "nvim-neo-tree/neo-tree.nvim",
    config = function()
      require("neo-tree").setup({
        sources = { "filesystem", "forester.sidebar" },
        forest = {
          window = {
            mappings = {
              --
            },
          },
        },
      })
      vim.keymap.set("n", "<leader>f", ":Neotree forest<CR>")
      vim.keymap.set("n", "\\", ":Neotree toggle<CR>")
    end,
  },
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("onedark")
    end,
  },
})

require("nvim-web-devicons").setup({ override_by_extension = { ["tree"] = { icon = "🌲" } } })
require("lualine").setup()

vim.keymap.set("n", "<leader>t", "<Plug>PlenaryTestFile %")
vim.keymap.set("n", "<leader>r", "<Plug>Lazy reload forester.nvim")
vim.opt.termguicolors = true
