# 🌲 forester.nvim 🌲

Filetype plugin for [forester](https://sr.ht/~jonsterling/forester/), a tool
for writing mathematical hypertext

# Features

- Tree-sitter syntax highlighting
  Please report any issues with the grammar in the [relevant repository](https://github.com/kentookura/tree-sitter-forester)
- following links and transclusions with `gf`
- Searching for trees by title with [telescope](https://github.com/nvim-telescope/telescope.nvim)
- Creating new trees via autocompletion menu
- Displaying tree titles with virtual text
- Address completion

Available user commands:

- `Forester build`: Build the currently configured forest. Use `Forester config` to switch forest.
- `Forester config`: Choose the config file from which to source the tree directories
- `Forester browse`: Telescope picker, search trees by title. TODO: support browsing by tag/taxon/...
- `Forester new`: Create a new tree by specifying a prefix
- `Forester new_random`: Create a new tree with a random adress by specifying a prefix
- `Forester transclude_new`: transclude a new tree at cursor position
- `Forester link_new`: link a new tree at cursor position

![screenshot of of the virtual text feature](https://github.com/kentookura/forester.nvim/blob/main/virtual-text.png?raw=true)

# Installation

With lazy:

```lua
  {
    "kentookura/forester.nvim",
    dependencies = {
      { "nvim-telescope/telescope.nvim" },
      { "nvim-treesitter/nvim-treesitter" },
      { "nvim-lua/plenary.nvim" },
      { "hrsh7th/nvim-cmp" },
    },
  },
```

You might need to run `:TSInstall toml` and `:TSInstall forester`.

# Configuration

In your `forest.toml` (or any other config) you should add the list of
prefixes:

```
prefixes = ["foo", "bar"]
```

When calling `:Forester new`, you will then be able to choose the prefix of the
new tree.

```lua
{
  config = function()
    local forester = require("forester")
    vim.g.mapleader = " "

    vim.keymap.set("n", "<leader>n.", "<cmd>Forester browse<CR>", { silent = true })
    vim.keymap.set("n", "<leader>nn", "<cmd>Forester new<CR>", { silent = true })
    vim.keymap.set("n", "<leader>nr", "<cmd>Forester new_random<CR>", { silent = true })
    vim.keymap.set("i", "<C-t>", "<cmd>Forester transclude<CR>", { silent = true })
    vim.keymap.set("i", "<C-l>", "<cmd>Forester link<CR>", { silent = true })
  end,
}

require("nvim-web-devicons").setup({ override_by_extension = { ["tree"] = { icon = "🌲" } } })
```

# Roadmap

- Find an ergonomic way to make use of forester's builtin templating feature
