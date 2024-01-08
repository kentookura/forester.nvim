# forester.nvim

Filetype plugin for [forester](https://sr.ht/~jonsterling/forester/), a tool
for writing mathematical hypertext

Status: experimental. Expect things to break.

## Installation

Install [forester](https://git.sr.ht/~jonsterling/ocaml-forester) either via
opam or nix.

With lazy:

```lua
  {
    "kentookura/forester.nvim",
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
    },
  },
```

See the example [init.lua](./init.lua)


## [Contributing/Roadmap](https://kentookura.srht.site/gld-000B.xml)

Currently assumes that trees are located in `./trees`.

## Features

- Tree-sitter syntax highlighting and concealing

![Screenshot showcasing the conceal feature](./doc/conceal.png)

- following links with `gf`

![Screen Recording showing the following of forester links in vim](./doc/link.gif)

- Open trees by searching for their title

![Screen Recording showing the browsing trees by title](./doc/search.gif)

- Creating new trees

![Screen Recording showing the creation of new trees](./doc/new.gif)
