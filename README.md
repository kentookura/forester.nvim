# 🌲 forester.nvim 🌲

Filetype plugin for [forester](https://sr.ht/~jonsterling/forester/), a tool
for writing mathematical hypertext

# Features

This plugin is pre-alpha, expect breaking changes.

- Tree-sitter syntax highlighting
  Please report any issues with the grammar in the [relevant repository](https://github.com/kentookura/tree-sitter-forester)
- following links and transclusions with `gf`
- Searching for trees by title with [telescope](https://github.com/nvim-telescope/telescope.nvim)
- Creating new trees without leaving your editor

Available user commands:

- `Forester browse`: Telescope picker, search trees by title. TODO: support browsing by tag/taxon/...
- `Forester new`: Create a new tree by specifying a prefix
- `Forester config`: Choose the config file from which to source the tree directories
- `Forester transclude_new`: transclude a new tree at cursor position
- `Forester link_new`: link a new tree at cursor position

There is ongoing work on the Forester LSP, so I am not going to put effort into supporting completion in this plugin.

# Installation

With lazy:

```lua
  {
    "kentookura/forester.nvim",
    dependencies = {
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
    vim.keymap.set("i", "<C-t>", "<cmd>Forester transclude<CR>", { silent = true })
    vim.keymap.set("i", "<C-l>", "<cmd>Forester link<CR>", { silent = true })
  end,
}

require("nvim-web-devicons").setup({ override_by_extension = { ["tree"] = { icon = "🌲" } } })
```

# Roadmap

- Adding more telescope pickers and previewers, making use of the `forester query` commands
- Link & transclude existing trees at cursor position.
- autocomplete
- ...
