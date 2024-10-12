local scan = require("plenary.scandir")
local path = require("plenary.path")

local os_sep = path.path.sep

local M = {}

local function filename(url)
  return url:match("[^/]+$")
end

local split_path = function(p)
  -- Returns the Path, Filename, and Extension as 3 values
  return string.match(p, "^(.-)([^\\/]-)(%.[^\\/%.]-)%.?$")
end

local to_addr = function(p)
  local _, addr, _ = split_path(p)
  return addr
end

local alphabet = {
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  "A",
  "B",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "J",
  "K",
  "L",
  "M",
  "N",
  "O",
  "P",
  "Q",
  "R",
  "S",
  "T",
  "U",
  "V",
  "W",
  "X",
  "Y",
  "Z",
}

local function encode(num)
  -- Check for number
  if type(num) ~= "number" then
    error("Number must be a number, not a string.", 1)
  end

  -- We can only accept positive numbers
  if num < 0 then
    error("Number must be a positive value.", 1)
  end

  -- Special case for numbers less than 36
  if num < 36 then
    return alphabet[num + 1]
  end

  -- Process large numbers now
  local result = ""
  while num ~= 0 do
    local i = num % 36
    result = alphabet[i + 1] .. result
    num = math.floor(num / 36)
  end
  return result
end

local function decode(b36)
  return tonumber(b36, 36)
end

local pad_addr = function(i)
  local base36_str = encode(i)
  local required_padding = 4 - #tostring(base36_str)
  if required_padding < 0 then
    return base36_str
  else
    return string.rep("0", required_padding) .. base36_str
  end
end

local compare_addr = function(a, b)
  return decode(a) < decode(b)
end

local function inc_addr(prefix, tree_num)
  return prefix .. "-" .. pad_addr(tree_num + 1)
end

local function next_addr() -- TODO bind these to <C-x> and <C-a>
  print("next_addr")
  -- pseudo:
  -- region = get_closest_addr() --with treesitter
  -- addr = parse_addr(region)
  -- overwrite(region, inc(addr))
  --
end

local function decr_addr(prefix, tree_num)
  return prefix .. "-" .. pad_addr(tree_num - 1)
end

local function prev_addr()
  print("prev_addr")
end

local function insert_at_cursor(content)
  local pos = vim.api.nvim_win_get_cursor(0)
  local r = pos[1]
  local c = pos[2]
  vim.api.nvim_buf_set_text(0, r - 1, c, r - 1, c, content)
end

local function map(iterable, f)
  local new = {}
  for i, v in pairs(iterable) do
    new[i] = f(v)
  end
  return new
end

local function filter(iterable, pred)
  local new = {}
  for i, v in pairs(iterable) do
    if pred(v) then
      new[i] = v
    end
  end
  return new
end

local function filter_map(iterable, f)
  local new = {}
  for i, v in pairs(iterable) do
    if f(v)[1] then
      do
        new[i] = f(v)[2]
      end
    else
    end
  end
  return new
end

local function fold(iterable, alg)
  if #iterable == 0 then
    return nil
  end
  local out = nil
  for i = 1, #iterable do
    out = alg(out, iterable[i])
  end
  return out
end

---@param fname string
local extract_id = function(fname)
  local pattern = "%-([^%.]+)%.%w+$"
  local id = string.match(fname, pattern)
  return decode(id)
end

local highest_in_dir = function(pfx, dir)
  local files = map(scan.scan_dir(dir), function(file)
    local split = vim.split(file, os_sep)
    return split[#split]
  end)
  local of_matching_pfx = filter(files, function(fn)
    return string.sub(fn, 1, pfx:len()) == pfx
  end)
  local ids = map(of_matching_pfx, extract_id)
  local sorted = {}
  for _, v in pairs(ids) do
    table.insert(sorted, v)
  end
  table.sort(sorted)
  local max = sorted[#sorted]
  if max then
    return { dir, max }
  else
  end
end

M.encode = encode
M.decode = decode
M.to_addr = to_addr
M.split_path = split_path
M.pad_addr = pad_addr
M.next_addr = next_addr
M.prev_addr = prev_addr
M.inc_addr = inc_addr
M.decr_addr = decr_addr
M.insert_at_cursor = insert_at_cursor
M.map = map
M.filter = filter
M.filter_map = filter_map
M.fold = fold
M.compare_addr = compare_addr
M.filename = filename
M.highest_in_dir = highest_in_dir

return M
