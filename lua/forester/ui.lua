-- This is code is WIP and does not get used yet.
local api = vim.api
local forester = require("forester.bindings")
local filter_map = require("forester.util").filter_map

local M = {}

local function create_title_cache()
  local success, trees = pcall(forester.query_all, vim.g.forester_current_config)
  if success then
    return filter_map(trees, function(tree)
      if tree.title ~= "" then
        return { true, tree.title }
      else
        return { false }
      end
    end)
  else
    return {}
  end
end

local title_cache = create_title_cache()

local NAMESPACE_ID = api.nvim_create_namespace("foresterUI")

local draw_inline_hints = function(bufnr)
  -- HACK: find more elegant way to refresh
  vim.api.nvim_buf_clear_namespace(bufnr, NAMESPACE_ID, 0, -1)

  local get_tree_root = function()
    local parser = vim.treesitter.get_parser(0)
    if parser ~= nil then
      local tree = parser:parse()[1]
      return tree:root()
    end
  end

  local addrs = vim.treesitter.query.parse("forester", [[(addr) @addr]])

  local root = get_tree_root()
  for _, node in addrs:iter_captures(root, bufnr, 0, -1) do
    local range = { node:range() }
    local title = title_cache[vim.treesitter.get_node_text(node, bufnr)]
    if title and title ~= vim.NIL then
      api.nvim_buf_set_extmark(
        bufnr,
        NAMESPACE_ID,
        range[1],
        range[2],
        { virt_text = { { title, "@comment" } }, virt_text_pos = "eol" }
      )
    end
  end
end

local function update_extmarks(bufnr)
  draw_inline_hints(bufnr)
end

local function get_extmarks_autocmd_callback()
  local callback = function(ev)
    update_extmarks(ev.buf)
  end
  return callback
end

M.draw_inline_hints = draw_inline_hints

M.setup = function()
  vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "TextChangedP" }, {
    pattern = { "*.tree" },
    callback = get_extmarks_autocmd_callback(),
  })
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = { "*.tree" },
    callback = function()
      title_cache = create_title_cache()
    end,
  })
end

return M
