local forester = require("forester.bindings")
local Config = require("forester.config")
local util = require("forester.util")
local map = util.map
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

-- Eventually this will be removed and become part of the LSP server
local FORESTER_BUILTINS = {
  { label = "verb", documentation = "" },
  { label = "startverb", documentation = "" },
  { label = "scope", documentation = "" },
  { label = "put", documentation = "" },
  { label = "put?", documentation = "" },
  { label = "get", documentation = "" },
  {
    label = "import",
    documentation = "\\import{xxx-NNNN} brings the functions exported by the tree xxx-NNNN into scope ",
  },
  {
    label = "export",
    documentation = "\\export{xxx-NNNN} brings the functions exported by the tree xxx-NNNN into scope, and exports them from the current tree ",
  },
  { label = "namespace", documentation = "" },
  { label = "open", documentation = "" },
  { label = "def", documentation = "" },
  { label = "alloc", documentation = "" },
  { label = "subtree", documentation = "" },
  { label = "object", documentation = "" },
  { label = "patch", documentation = "" },
  { label = "call", documentation = "" },
  {
    label = "p",
    documentation = "creates a paragraph; unlike Markdown, it is mandatory to annotate paragraphs explicitly",
  },
  { label = "em", documentation = "typesets the content in italics" },
  { label = "strong", documentation = "typesets the content in boldface" },
  { label = "li", documentation = "creates a list item" },
  { label = "ol", documentation = "creates an ordered list" },
  { label = "ul", documentation = "creates an unordered list" },
  { label = "code", documentation = "typesets the content in monospace" },
  { label = "blockquote", documentation = "blockquote" },
  { label = "pre", documentation = "preformatted text" },
  { label = "figure", documentation = "" },
  { label = "figcaption", documentation = "" },
  { label = "transclude", documentation = "transclude a tree as a subsection" },
  { label = "tex", documentation = "" },
  { label = "ref", documentation = "" },
  { label = "title", documentation = "sets the title of the tree; can contain mainmatter markup" },
  {
    label = "taxon",
    documentation = "sets the taxon of the tree; example taxa include lemma, theorem, person, reference; the latter two taxa are treated specially by Forester for tracking biographical and bibliographical trees respectively",
  },
  { label = "date", documentation = "sets the creation date of the tree" },
  { label = "meta", documentation = "" },
  {
    label = "author",
    documentation = "\\author{name} sets the author of the tree to be the biographical tree at address name",
  },
  { label = "author/literal", documentation = "" },
  { label = "contributor", documentation = "" },
  { label = "contributor/literal", documentation = "" },
  { label = "parent", documentation = "" },
  { label = "number", documentation = "" },
  { label = "tag", documentation = "" },
  { label = "query", documentation = "" },
  { label = "query/rel", documentation = "" },
  { label = "query/rel/literal", documentation = "" },
  { label = "query/union", documentation = "" },
  { label = "query/isect", documentation = "" },
  { label = "query/isect-fam", documentation = "" },
  { label = "query/union-fam", documentation = "" },
  { label = "query/isect-fam-rel", documentation = "" },
  { label = "query/union-fam-rel", documentation = "" },
  { label = "query/compl", documentation = "" },
  { label = "query/tag", documentation = "" },
  { label = "query/taxon", documentation = "" },
  { label = "query/author", documentation = "" },
  { label = "query/author/literal", documentation = "" },
  { label = "query/incoming", documentation = "" },
  { label = "query/outgoing", documentation = "" },
  { label = "query/edges", documentation = "" },
  { label = "query/paths", documentation = "" },
  { label = "rel/tags", documentation = "" },
  { label = "rel/taxa", documentation = "" },
  { label = "rel/authors", documentation = "" },
  { label = "rel/contributors", documentation = "" },
  { label = "rel/transclusion", documentation = "" },
  { label = "rel/links", documentation = "" },
}

local default_items = {}
for _, v in pairs(FORESTER_BUILTINS) do
  table.insert(
    default_items,
    { label = v.label, insertText = v.label .. "{", documentation = { kind = "markdown", value = v.documentation } }
  )
end

local cache

local function refresh_cache()
  local _, res = pcall(forester.query_all, vim.g.forester_current_config)
  cache = res
end

refresh_cache()

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = { "*.tree" },
  callback = function()
    vim.schedule(refresh_cache)
  end,
})

function source:complete(params, callback)
  local input = string.sub(params.context.cursor_before_line, params.offset - 1)
  local text_before_cursor = params.context.cursor_before_line
  if vim.startswith(input, "\\") then
    callback(default_items)
  else
    local items = {}
    local prefix_items = map(Config.all_prefixes(), function(pfx)
      return {
        label = pfx,
        documentation = "create a new tree with prefix `" .. pfx .. "`",
        data = { isPrefix = true },
      }
    end)
    local prefix_random_items = map(Config.all_prefixes(), function(pfx)
      return {
        label = pfx,
        filterText = pfx .. " " .. "random",
        documentation = "create a new tree with prefix `" .. pfx .. "` (randomized id)",
        labelDetails = { description = "random" },
        data = { isPrefix = true, isRandom = true },
      }
    end)
    for _, v in pairs(prefix_items) do
      table.insert(items, v)
    end
    for _, v in pairs(prefix_random_items) do
      table.insert(items, v)
    end
    local function insert_text(addr)
      if ends_with_one_of(triggers_for_closing_brace, text_before_cursor) then
        return addr .. "}"
      elseif vim.endswith(text_before_cursor, "](") then
        return addr .. ")"
      elseif vim.endswith(text_before_cursor, "[[") then
        return addr .. "]]"
      end
    end
    for addr, data in pairs(cache) do
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
        data = { isPrefix = false },
      })
    end
    callback({ items = items, isIncomplete = true })
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
---@param item lsp.CompletionItem
---@param callback fun(item: lsp.CompletionItem|nil)
function source:execute(item, callback)
  local data = item.data
  if data == nil or data.isPrefix == nil then
    callback(item)
  elseif data.isPrefix then
    local pfx = item.label
    local path = Config.dir_of_latest_tree_of_prefix(pfx)
    local new_tree
    if data.isRandom ~= nil and data.isRandom then
      new_tree = forester.new_random(pfx, path, vim.g.forester_current_config)[1]
    else
      new_tree = forester.new(pfx, path, vim.g.forester_current_config)[1]
    end
    -- I no longer understand this string pattern, but it gets the foo-XXXX out of foo-XXXX.tree
    local addr = util.filename(new_tree):match("(.+)%..+$")
    -- last 5 chars: -XXXX
    local id = string.sub(addr, -5)
    vim.api.nvim_put({ id .. "}" }, "c", true, true)
    callback()
  else
    callback(item)
  end
end

return source
