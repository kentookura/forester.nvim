# forester.nvim

**Note: This plugin is a work in progress and is currently unusable.
Furthermore it makes use of some features that I implemented which are
currently not part of the main branch of forester. Currently assumes that trees
are located in `./trees`
**

Filetype plugin for [forester](https://sr.ht/~jonsterling/forester/), a tool
for writing mathematical hypertext

## Features

- following links using `gf`
- creating new trees using `ForestNew`

## Required dependencies

- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

`forester` needs to be in `$PATH`

## Installation

Should work with your favorite plugin manager. Please report any issues.

## Roadmap

Feel free to open PRs for any of these.

- [ ] configuring tree directories

- [ ] factor out visual selection to transclusion:

  When a visual selection is made, prompt for a prefix and replace the
  selection with a transclusion of the new tree.

- [ ] following links inside of nvim.

- [ ] search titles and navigate with telescope

  We can probably use `forester complete` for this.

- [ ] Better syntax highlighting
- [ ] devicons for trees
- [ ] click browser link to open in nvim
