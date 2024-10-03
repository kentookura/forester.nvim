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

local triggers_for_closing_brace = {
  "\\transclude{",
  "\\import{",
  "\\export{",
  "\\author{",
  "\\contributor{",
}

local function any(table, pred)
  for _, v in pairs(table) do
    if pred(v) then
      return true
    else
      do
      end
    end
  end
  return false
end

local function ends_with_one_of(table, str)
  return any(table, function(i)
    return vim.endswith(str, i)
  end)
end

local FORESTER_BUILTINS = {
  "p",
  "em",
  "strong",
  "li",
  "ol",
  "ul",
  "code",
  "blockquote",
  "pre",
  "figure",
  "figcaption",
  "transclude",
  "tex",
  "ref",
  "title",
  "taxon",
  "date",
  "meta",
  "author",
  "author/literal",
  "contributor",
  "contributor/literal",
  "parent",
  "number",
  "tag",
  "query",
  "query/rel",
  "query/rel/literal",
  "query/union",
  "query/isect",
  "query/isect-fam",
  "query/union-fam",
  "query/isect-fam-rel",
  "query/union-fam-rel",
  "query/compl",
  "query/tag",
  "query/taxon",
  "query/author",
  "query/author/literal",
  "query/incoming",
  "query/outgoing",
  "query/edges",
  "query/paths",
  "rel/tags",
  "rel/taxa",
  "rel/authors",
  "rel/contributors",
  "rel/transclusion",
  "rel/links",
}

function source:complete(params, callback)
  local input = string.sub(params.context.cursor_before_line, params.offset - 1)
  local text_before_cursor = params.context.cursor_before_line
  if vim.startswith(input, "\\") then
    local items = {}
    for _, v in pairs(FORESTER_BUILTINS) do
      table.insert(items, { label = v, insertText = v .. "{" })
    end
    callback(items)
  else
    local items = {}
    local trees = forester.query_all(vim.g.forester_current_config)
    local function insert_text(addr)
      if ends_with_one_of(triggers_for_closing_brace, text_before_cursor) then
        return addr .. "}"
      elseif vim.endswith(text_before_cursor, "](") then
        return addr .. ")"
      elseif vim.endswith(text_before_cursor, "[[") then
        return addr .. "]]"
      end
    end
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
        insertText = insert_text(addr),
        documentation = title,
        detail = addr,
      })
    end
    callback({ items = items })
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
