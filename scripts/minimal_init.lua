-- Add current directory to 'runtimepath' to be able to use 'lua' files
vim.cmd([[let &rtp.=','.getcwd()]])

-- Set up 'mini.test' only when calling headless Neovim (like with `make test`)
-- if #vim.api.nvim_list_uis() == 0 then
-- Add 'mini.nvim' to 'runtimepath' to be able to use 'mini.test'
-- Assumed that 'mini.nvim' is stored in 'deps/mini.nvim'
vim.cmd("set rtp+=deps/plenary.nvim")
vim.cmd("set rtp+=deps/mini.nvim")
vim.cmd("set rtp+=deps/telescope.nvim")
vim.cmd("set rtp+=deps/nvim-treesitter")
vim.cmd("set rtp+=scripts/minidoc")

require("nvim-treesitter.configs").setup({ ensure_installed = { "toml" }, auto_install = true, sync_install = true })

require("mini.test").setup()
require("mini.doc").setup()
-- require("mini.doc").setup()
-- end
