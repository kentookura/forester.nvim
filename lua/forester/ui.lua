local api = vim.api

local M = {}

local NAMESPACE = "foresterUI"

local draw_title_inlay = function(bufnr, pos, title)
  local r = pos[1]
  local c = pos[2]
  api.nvim_buf_set_extmark(bufnr, forester_ns, r, c, { virt_text = { { title, "@comment" } }, virt_text_pos = "eol" })
end

local draw_inline_hints = function(bufnr)
  local get_tree_root = function()
    local parser = vim.treesitter.get_parser(0)
    local tree = parser:parse()[1]
    return vim.inspect(tree:root())
  end

  local addrs = vim.treesitter.query.parse("forester", [[(addr) @addr]])

  local query_title = function(addr)
    return "TODO"
  end

  local root = get_tree_root()
  local marks = {}
  local changes = {}
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
-- local update_extmarks

local function update_extmarks(bufnr, ns_id, ui_opts)
  draw_inline_hints(bufnr)
end

local function get_extmarks_autocmd_callback(ui_opts)
  local ns_id = vim.api.nvim_create_namespace(NAMESPACE)
  local callback = function(ev)
    update_extmarks(ev.buf, ns_id, ui_opts)
  end
  return callback
end

M.draw_title_inlay = draw_title_inlay
M.draw_inline_hints = draw_inline_hints

M.setup = function(ui_opts)
  if ui_opts.enable == false then
    return
  end
  local group = vim.api.nvim_create_augroup("forester_inlay_hints", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "TextChangedP" }, {
    callback = get_extmarks_autocmd_callback(ui_opts),
  })
end

return M
