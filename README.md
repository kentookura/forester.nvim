# forester.nvim

Filetype plugin for [forester](https://sr.ht/~jonsterling/forester/), a tool
for writing mathematical hypertext

## Installation

Install [forester](https://git.sr.ht/~jonsterling/ocaml-forester) either via
opam or nix.

See the example configs

- [lazy.lua](./lazy.lua).

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
