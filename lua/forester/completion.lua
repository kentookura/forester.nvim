local forester = require("forester.bindings")
local util = require("forester.util")
local source = {}

---Return whether this source is available in the current context or not (optional).
---@return boolean
function source:is_available()
  return true
end

---Return the debug name of this source (optional).
---@return string
function source:get_debug_name()
  return "forester"
end

---Return LSP's PositionEncodingKind.
---@NOTE: If this method is omitted, the default value will be `utf-16`.
---@return lsp.PositionEncodingKind
function source:get_position_encoding_kind()
  return "utf-16"
end

---Return the keyword pattern for triggering completion (optional).
---If this is omitted, nvim-cmp will use a default keyword pattern. See |cmp-config.completion.keyword_pattern|.
---@return string
function source:get_keyword_pattern()
  return [[\k\+]]
end

---Return trigger characters for triggering completion (optional).
function source:get_trigger_characters()
  return { "\\", "(", "{" }
end

function source:complete(params, callback)
  local input = string.sub(params.context.cursor_before_line, params.offset - 1)
  vim.notify(vim.inspect(params.context.cursor_before_line))
  if params.context.cursor_before_line == "\\transclude{" then
    local items = {}
    local trees = forester.query_all(vim.g.forester_current_config)
    for addr, data in pairs(trees) do
      local title
      if data.title == vim.NIL then
        title = "<untitled>"
      else
        title = data.title
      end
      table.insert(items, {
        filterText = addr .. " " .. title,
        label = addr,
        insertText = addr .. "}",
        documentation = title,
        detail = addr,
      })
    end
    callback({ items = items })
  end
  if vim.startswith(input, "(") then
    local items = {}
    local trees = forester.query_all(vim.g.forester_current_config)
    for addr, data in pairs(trees) do
      local title
      if data.title == vim.NIL then
        title = "<untitled>"
      else
        title = data.title
      end
      table.insert(items, {
        filterText = addr .. " " .. title,
        label = title .. " (" .. addr .. ")",
        insertText = addr,
        documentation = nil,
        detail = addr,
      })
    end
    callback({ items = items })
  elseif vim.startswith(input, "\\") then
    callback({
      { label = "title", insertText = "title{" },
      { label = "author", insertText = "author{" },
      { label = "date", insertText = "date{" },
      { label = "taxon", insertText = "taxon{" },
      { label = "def", insertText = "def{" },
      { label = "import", insertText = "import{" },
      { label = "export", insertText = "export{" },
      { label = "p", insertText = "p{" },
      { label = "strong", insertText = "strong{" },
      { label = "transclude", insertText = "transclude{" },
      { label = "let", insertText = "let{" },
      { label = "code", insertText = "code{" },
      { label = "tex", insertText = "tex{" },
    })
  end
end

---Resolve completion item (optional). This is called right before the completion is about to be displayed.
---Useful for setting the text shown in the documentation window (`completion_item.documentation`).
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
  callback(completion_item)
end

---Executed after the item was selected.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
  callback(completion_item)
end

return source
