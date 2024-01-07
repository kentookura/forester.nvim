return function(opts)
  opts = opts or {}
  local links = generate_links()

  pickers
    .new(opts, {
      prompt_title = "Insert Link",
      results_title = "Linkables",
      finder = finders.new_table({
        results = links,
        entry_maker = function(entry)
          local displayer = entry_display.create({
            separator = ": ",
            items = {
              { width = 30 },
              { remaining = true },
            },
          })
          local function make_display(ent)
            if entry.file then
              return displayer({
                { ent.file:sub(-30, -1), "NeorgLinkFile" },
                { ent.ordinal, "NeorgLinkText" },
              })
            else
              return displayer({
                { ent.ordinal, "NeorgLinkText" },
              })
            end
          end
          -- if not entry.file then
          -- entry.file = vim.fn.expand("%:r")
          -- end
          return {
            value = entry.line,
            display = make_display,
            ordinal = entry.display,
            lnum = entry.line,
            file = entry.file,
            linkable = entry.linkable,
          }
        end,
      }),
      -- I couldn't get syntax highlight to work with this :(
      previewer = nil,
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr)
        actions_set.select:replace(function()
          local entry = state.get_selected_entry()
          actions.close(prompt_bufnr)

          local inserted_file = (function()
            if entry.file then
              -- entry.display = string.gsub(entry.display, entry.file..": ", "")
              return ":" .. entry.file .. ":"
            else
              return ""
            end
          end)()

          if inserted_file ~= "" then
            vim.api.nvim_put({
              "{" .. inserted_file .. entry.ordinal:gsub("^(%W+)%s+.+", "%1 ") .. entry.linkable:gsub(
                "[%*#%|_]",
                "\\%1"
              ) .. "}" .. "[" .. entry.linkable:gsub(":$", "") .. "]",
            }, "c", false, true)
          else
            vim.api.nvim_put({
              "{" .. inserted_file .. entry.ordinal:gsub("^(%W+)%s+.+", "%1 ") .. entry.linkable:gsub(
                "[%*#%|_]",
                "\\%1"
              ) .. "}",
            }, "c", false, true)
          end
          vim.api.nvim_feedkeys("hf]a", "t", false)
        end)
        return true
      end,
    })
    :find()
end
