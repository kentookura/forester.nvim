local forester = require("forester")
local util = require("forester.util")
local scan = require("plenary.scandir")

local tree_dir = "test/trees"

forester.transclude_tree(tree_dir)
forester.link_tree(tree_dir)
