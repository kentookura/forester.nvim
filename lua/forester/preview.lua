local api, fn = vim.api, vim.fn
local M = {}

local hover_provider = {
  name = "Tree Preview",
  enabled = function(bufnr)
    return true
  end,
  execute = function(opts, done) -- TODO: get rendered text from forester
    vim.cmd("normal yi{")
    vim.print(vim.fn.getreg())

    done({ lines = { "hello" }, filetype = "tree" })
  end,
}

M.hover_provider = hover_provider

return M
