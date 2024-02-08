local M = {}

local hover_provider = {
  name = "Forester",
  enabled = function(bufnr)
    return true
  end,
  execute = function(opts, done)
    done({ lines = { "test" }, filetype = "tree" })
  end,
}

M.provider = hover_provider

return M
