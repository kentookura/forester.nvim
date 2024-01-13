local api = vim.api
local forester_ns = api.nvim_create_namespace("forester.extmarks")

local M = {}

local draw_title_inlay = function(bufnr, pos, title)
  local r = pos[1]
  local c = pos[2]
  api.nvim_buf_set_extmark(bufnr, forester_ns, r, c, { virt_text = { { title, "@comment" } }, virt_text_pos = "eol" })
end

local draw_inline_hints = function(bufnr)
  local get_tree_root = function()
    local parser = vim.treesitter.get_parser(0)
    local tree = parser:parse()[1]
    --vim.print(vim.inspect(tree:root()))
  end

  local addrs = vim.treesitter.query.parse("forester", [[(addr) @addr]])

  local query_title = function(addr)
    return "TODO"
  end

  local marks = {}
  for id, node in addrs:iter_captures(root, bufnr, 0, -1) do
    local name = addrs.captures[id]
    -- {start row, start col, end row, end col}
    local range = { node:range() }

    table.insert(changes, 1, {
      start = range[1],
      final = range[3],
      title = query_title(id),
    })
    for _, mark in ipairs(marks) do
      draw_title_inlay(bufnr, { mark.start, mark.final }, mark.title)
    end
  end
end

M.draw_title_inlay = draw_title_inlay
M.draw_inline_hints = draw_inline_hints

return M
