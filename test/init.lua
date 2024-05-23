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
    config = function()
      local forester = require("forester").setup()

      vim.keymap.set("n", "<leader>n.", "<cmd>Forester browse<CR>", { silent = true })
      vim.keymap.set("n", "<leader>nn", "<cmd>Forester new<CR>", { silent = true })
      -- vim.keymap.set("n", "<leader>k", require("hover").hover, { desc = "hover.nvim" })
      -- vim.keymap.set("i", "<C-t>", "<cmd>Forester transclude<CR>", { silent = true })
      -- vim.keymap.set("i", "<C-l>", "<cmd>Forester link<CR>", { silent = true })
    end,
    dependencies = {
      { "L3MON4D3/LuaSnip" },
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
})

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = "menu,menuone,noinsert",
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete({}),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
    { name = "forester" },
  },
})

--require("nvim-web-devicons").setup({ override_by_extension = { ["tree"] = { icon = "🌲" } } })
vim.keymap.set("n", "<leader>t", "<Plug>PlenaryTestFile %")
vim.keymap.set("n", "<leader>r", "<Plug>Lazy reload forester.nvim")
vim.opt.termguicolors = true
