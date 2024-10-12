local M = {}

M.check = function()
  vim.health.start("forester.nvim report")

  if vim.fn.executable("forester") == 1 then
    vim.health.ok("forester is executable")
  else
    vim.health.error("could not find executable `forester`")
  end
end

return M
