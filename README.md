# forester.nvim

Filetype plugin for [forester](https://sr.ht/~jonsterling/forester/), a tool
for writing mathematical hypertext

## [Contributing/Roadmap](https://kentookura.srht.site/gld-000B.xml)

Note: This plugin makes use of some features that I implemented on some
branches which are currently only part of the
[ `neovim-support` ](https://git.sr.ht/~kentookura/ocaml-forester/tree/nvim-support)
branch of my fork of forester on sourcehut

Currently assumes that trees are located in `./trees`.

## Features

### following links using `gf`

![Screen Recording showing the following of forester links in vim](doc/link.gif)

### following links using `<leader>n.`

![Screen Recording showing the browsing trees by title](doc/search.gif)

### new trees `<leader>nn`

![Screen Recording showing the creation of new trees](doc/new.gif)

## Required dependencies

- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

`forester` needs to be in `$PATH`

## Installation

Should work with your favorite plugin manager. Please report any issues.
