local M = {}

local _config = {}

function M.setup(config)
  vim.filetype.add({ extension = { tree = "tree" } })
  vim.cmd([[
    let b:current_syntax = 'tree'
  ]])
  require("notify")("forester.nvim loaded")
end

local attach_to_buffer = function(bufnr, command)
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("forester", { clear = true }),
    pattern = "*.tree",
    callback = function()
      local append_data = function(_, data)
        if data then
          vim.api.nvim_buf_set_lines(output_bufnr, -1, -1, false, data)
        end
      end
      vim.api.nvim_buf_set_lines(output_bufnr, 0, -1, false, { "output: " })
      vim.fn.jobstart(command, {
        stdout_buffered = true,
        on_stdout = append_data,
        on_stderr = append_data,
      })
    end,
  })
end

vim.api.nvim_create_user_command("Forest", function()
  local prefixes = {}
  vim.fn.jobstart({ "dune", "exec", "forester", "--", "query", "prefix", "trees" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        print(vim.inspect(data))
        vim.ui.select(data, {
          prompt = "prefix of new tree",
          format_item = function(item)
            return item
          end,
        }, function(choice)
          vim.fn.jobstart({ "dune", "exec", "forester", "--", "new", "--prefix", choice, "--dir", "trees" }, {
            on_stderr = function(_, res)
              print(vim.inspect(res))
            end,
            on_stdout = function(_, res)
              print(vim.inspect(res))
            end,
          })
        end)
      end
    end,
    on_stderr = function(_, data)
      if data then
        print(vim.inspect(data))
      end
    end,
  })
end, {})

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
