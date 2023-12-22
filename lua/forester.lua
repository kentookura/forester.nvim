local M = {}

local _config = {}

function M.setup(config)
  vim.filetype.add({ extension = { tree = "tree" } })
  vim.cmd([[
    if exists('b:current_syntax')
      finish
    endif
    echom "custom syntax highlighting"
    let b:current_syntax = 'tree'
  ]])
  require("notify")("forester.nvim loaded")
end

--vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--  pattern = "*.tree",
--  callback = function()
--    local buf = vim.api.nvim_get_current_buf()
--    vim.api.nvim_buf_set_option(buf, "filetype", "tree")
--  end,
--})

--if vim.fn.has("nvim-0.7.0") == 0 then
--  vim.api_err_writeln("forester requires at least-0.7.0.1")
--  return
--end
--
--vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--  pattern = "*.tree",
--  command = "setfiletype tree",
--})
--
--vim.lsp.start({
--  name = "forester-lsp",
--  cmd = { forester_lsp },
--  root_dir = vim.fs.dirname(vim.fs.find({ "trees" }, { upward = true })[1]),
--})
--
--vim.api.nvim_create_autocmd("LspAttach", {
--  callback = function(args)
--    local bufnr = args.buf
--    local client = vim.lsp.get_client_by_id(args.data.client_id)
--    if client.server_capabilities.completionProvider then
--      vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
--    end
--    if client.server_capabilities.definitionProvider then
--      vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
--    end
--  end,
--})
--
--vim.api.nvim_create_autocmd("BufRead,BufNew *.tree", {
--  callback = function(args)
--    vim.lsp.buf_attach_client(0, 3)
--  end,
--})

return M
