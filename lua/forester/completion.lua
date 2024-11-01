--- Autocomplete for builtin functions and tree addresses
local forester = require("forester.bindings")
local config = require("forester.config")
local util = require("forester.util")
local FORESTER_BUILTINS = require("forester.consts").FORESTER_BUILTINS
local map = util.map
local source = {}
local cache = {}

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
  "transclude{",
  "import{",
  "export{",
  "author{",
  "contributor{",
}

local default_items = {}
for _, v in pairs(FORESTER_BUILTINS) do
  table.insert(
    default_items,
    { label = v.label, insertText = v.label .. "{", documentation = { kind = "markdown", value = v.documentation } }
  )
end

local function refresh_cache()
  local success, res = pcall(forester.query_all, vim.g.forester_current_config)
  if success then
    cache = res
  end
end

refresh_cache()

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = { "*.tree" },
  callback = function()
    vim.schedule(refresh_cache)
  end,
})

function source:closing_delim(text_before_cursor)
  local candidate = { -1, "" }
  for _, v in pairs(triggers_for_closing_brace) do
    local _, e = string.find(text_before_cursor, v)
    if e ~= nil and candidate[1] < e then
      candidate = { e, "}" }
    end
  end
  local _, e = string.find(text_before_cursor, "%]%(")
  if e ~= nil and candidate[1] < e then
    candidate = { e, ")" }
  end
  local _, e = string.find(text_before_cursor, "%[%[")
  if e ~= nil and candidate[1] < e then
    candidate = { e, "]]" }
  end
  return candidate[2]
end

function source:complete(params, callback)
  local input = string.sub(params.context.cursor_before_line, params.offset - 1)
  local text_before_cursor = params.context.cursor_before_line
  if vim.g.forester_current_config == nil then
    return
  else
    if vim.startswith(input, "\\") then
      callback(default_items)
    else
      local items = {}
      local prefix_items = {}
      local prefix_random_items = {}
      if vim.g.forester_current_config.prefixes ~= nil then
        prefix_items = map(vim.g.forester_current_config.prefixes, function(pfx)
          return {
            label = pfx,
            documentation = "create a new tree with prefix `" .. pfx .. "`",
            data = { isPrefix = true },
          }
        end)

        prefix_random_items = map(vim.g.forester_current_config.prefixes, function(pfx)
          return {
            label = pfx,
            filterText = pfx .. " " .. "random",
            documentation = "create a new tree with prefix `" .. pfx .. "` (randomized id)",
            labelDetails = { description = "random" },
            data = { isPrefix = true, isRandom = true, closingDelim = source:closing_delim(text_before_cursor) },
          }
        end)
      end
      for _, v in pairs(prefix_items) do
        table.insert(items, v)
      end
      for _, v in pairs(prefix_random_items) do
        table.insert(items, v)
      end
      local function insert_text(addr)
        return addr .. source:closing_delim(text_before_cursor)
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
          data = { isPrefix = false },
        })
      end
      callback({ items = items, isIncomplete = true })
    end
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
    local path = config.dir_of_latest_tree_of_prefix(pfx)
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
    local closing_delim = data.closingDelim or ""
    vim.api.nvim_put({ id .. closing_delim }, "c", true, true)
    callback()
  else
    callback(item)
  end
end

return source
