local M = {}
local forester = require("forester.bindings")
local job = require("plenary.job")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local keymap = vim.keymap.set
local default_opts = { noremap = true, silent = true }

local _config = {}

local forest = {}
forest.tree_dir = "trees"

local tree_dir = forest.tree_dir

local function new_tree()
  local function edit_callback(res)
    vim.cmd("edit " .. res:result()[1]) -- ugh
  end

  local function select(prefixes)
    vim.ui.select(prefixes:result(), {}, function(prefix)
      forester.new(prefix, tree_dir, edit_callback)
    end)
  end

  forester.query("prefix", tree_dir, select)
end

local function new_from_template()
  local function select_prefix(template_addr)
    return function(prefixes)
      vim.ui.select(
        prefixes,
        { prompt = "select a prefix" },
        vim.schedule_wrap(function(prefix)
          forester.template(prefix, template_addr, tree_dir)
        end)
      )
    end
  end

  local function select_template(templates)
    vim.ui.select(
      templates,
      { prompt = "select a emplate" },
      vim.schedule_wrap(function(template)
        local tmpl_addr = template:match("^([^.]+)")
        forester.query("prefix", tree_dir, select_prefix(tmpl_addr))
      end)
    )
  end

  job
    :new({
      command = "ls",
      args = { "templates" },
      on_exit = vim.schedule_wrap(function(j, _)
        select_template(j:result())
      end),
    })
    :sync()
end

local function open_tree()
  local function select(data)
    vim.ui.select(data:result(), {
      prompt = "Titles",
      format_item = function(item)
        local addr = item:match("[^, ]*$")
        local title = item:match("[^,]+$")
        return title
      end,
    }, function(choice)
      local addr = choice:match("[^,%s]+")
      local path = vim.fn.findfile(addr .. ".tree", tree_dir .. "/**")
      vim.cmd("edit " .. path)
    end)
  end

  forester.complete(tree_dir, select)
end

vim.api.nvim_create_user_command("ForestNew", new_tree, {})
vim.api.nvim_create_user_command("ForestTemplate", new_from_template, {})
vim.api.nvim_create_user_command("ForestOpen", open_tree, {})

function M.setup(config)
  vim.filetype.add({ extension = { tree = "tree" } })
  vim.cmd([[
    let b:current_syntax = 'tree'
  ]])

  -- enable opening of forester links
  vim.opt.path:append(tree_dir)
  vim.opt.suffixesadd:prepend(".tree")

  keymap("n", "<leader>nn", new_tree, default_opts)
  keymap("n", "<leader>nt", new_from_template, default_opts)
  keymap("n", "<leader>n.", open_tree, default_opts)
end

return M
