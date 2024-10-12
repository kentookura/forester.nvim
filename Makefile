# Run all test files
test: deps/mini.nvim
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

# Run test from file at `$FILE` environment variable
test_file: deps/mini.nvim
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run_file('$(FILE)')"

# Download dependencies:
# TODO: remove as much as possible
deps:
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/echasnovski/mini.nvim $@/mini.nvim
	git clone --filter=blob:none https://github.com/nvim-lua/plenary.nvim $@/plenary.nvim
	git clone --filter=blob:none https://github.com/nvim-telescope/telescope.nvim $@/telescope.nvim
	git clone --filter=blob:none https://github.com/nvim-treesitter/nvim-treesitter $@/nvim-treesitter

documentation:
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "luafile scripts/minidoc.lua" -c "qa!"

documentation-ci: deps documentation

test-ci: deps test
