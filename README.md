# forester.nvim

Filetype plugin for [forester](https://sr.ht/~jonsterling/forester/), a tool
for writing mathematical hypertext

## [Contributing/Roadmap](https://kentookura.srht.site/gld-000B.xml)

Currently assumes that trees are located in `./trees`.

## Features

### Tree-sitter syntax highlighting and concealing

![Screenshot showcasing the syntax highlighting](doc/syntax.png)
![Screenshot showcasing the concealing](doc/conceal.png)

### following links using `gf`

![Screen Recording showing the following of forester links in vim](doc/link.gif)

### searching titles using `<leader>n.`

![Screen Recording showing the browsing trees by title](doc/search.gif)

### new trees `<leader>nn`

![Screen Recording showing the creation of new trees](doc/new.gif)

## Required dependencies

- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

`forester` needs to be in `$PATH`

## Installation

Should work with your favorite plugin manager. Please report any issues.
