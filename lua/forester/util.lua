local M = {}

--local addr = item:match("[^, ]*$")
--local title = item:match("[^,]+$")

local split_path = function(path)
  -- Returns the Path, Filename, and Extension as 3 values
  return string.match(path, "^(.-)([^\\/]-)(%.[^\\/%.]-)%.?$")
end

local to_addr = function(path)
  local _, addr, _ = split_path(path)
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
    error("Number must be a number, not a string. Silly user.", 1)
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

M.encode = encode
M.decode = decode
M.to_addr = to_addr
M.split_path = split_path

return M
