# forester.nvim

Filetype plugin for [forester](https://sr.ht/~jonsterling/forester/), a tool
for writing mathematical hypertext

## Installation

Install [forester](https://git.sr.ht/~jonsterling/ocaml-forester) either via
opam or nix.

With lazy:

```lua
  {
    "kentookura/forester.nvim",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
      { "nvim-lua/plenary.nvim" },
    },
  },
```

See also the example [init.lua](./init.lua)


## Features

- Tree-sitter syntax highlighting and concealing

![Screenshot showcasing the conceal feature](./doc/conceal.png)

- following links with `gf`

![Screen Recording showing the following of forester links in vim](./doc/link.gif)

- Open trees by searching for their title

![Screen Recording showing the browsing trees by title](./doc/search.gif)

- Creating new trees

![Screen Recording showing the creation of new trees](./doc/new.gif)

## Design Notes

Forester enforces uniqueness of addresses per forest. This plugin is designed
to work with multiple forests, so how should we handle duplicate addresses?
