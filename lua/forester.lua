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
    vim.ui.select(prefixes, {}, function(prefix)
      --vim.ui.select(prefixes:result(), {}, function(prefix)
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

local function split_path(path)
  -- Returns the Path, Filename, and Extension as 3 values
  return string.match(path, "^(.-)([^\\/]-)(%.[^\\/%.]-)%.?$")
end

local function transclude_selection()
  local function callback(data)
    local path = data:result()[1]
    local _, addr, _ = split_path(path)
    local content = "\\transclude{" .. addr .. "}"

    vim.api.nvim_feedkeys("c", "v", false)
    vim.api.nvim_feedkeys(content, "i", false)
    print(content)
    --vim.cmd("edit " .. path)
    --vim.api.nvim_feedkeys("Go", "n", false)
    --vim.api.nvim_feedkeys(content, "i", false)
  end

  local function select_prefix()
    return function(prefixes)
      vim.ui.select(
        prefixes,
        { prompt = "select a prefix" },
        vim.schedule_wrap(function(prefix)
          forester.new(prefix, tree_dir, callback)
        end)
      )
    end
  end
  forester.query("prefix", tree_dir, select_prefix())
end

local function transclude_new()
  local function put(content)
    local pos = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local nline = line:sub(0, pos) .. content .. line:sub(pos + 1)
    vim.api.nvim_set_current_line(nline)
  end

  local function callback(data)
    local path = data:result()[1]
    local _, addr, _ = split_path(path)
    local content = "\\transclude{" .. addr .. "}"

    put(content)
    vim.cmd("edit " .. path)
    --vim.api.nvim_feedkeys("Go", "n", false)
    --vim.api.nvim_feedkeys(content, "i", false)
  end
  local function select_prefix()
    return function(prefixes)
      vim.ui.select(
        prefixes,
        { prompt = "select a prefix" },
        vim.schedule_wrap(function(prefix)
          forester.new(prefix, tree_dir, callback)
        end)
      )
    end
  end
  forester.query("prefix", tree_dir, select_prefix())
end

vim.api.nvim_create_user_command("ForestNew", new_tree, {})
vim.api.nvim_create_user_command("ForestTemplate", new_from_template, {})
vim.api.nvim_create_user_command("ForestOpen", open_tree, {})
vim.api.nvim_create_user_command("ForestTranscludeNew", transclude_new, {})
vim.api.nvim_create_user_command("ForestTranscludeSelection", transclude_selection, {})

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
  keymap("n", "<leader>nh", transclude_new, default_opts)
  keymap("v", "<leader>t", transclude_selection, { noremap = true, silent = true })
end

return M
