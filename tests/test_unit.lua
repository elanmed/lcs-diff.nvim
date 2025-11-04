local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

local T = new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua", }
      child.lua [[M = require('lcs-diff')]]
    end,
    post_once = child.stop,
  },
}

--- @param type DiffRecordType
--- @param line string
--- @return DiffRecord
local function rec(type, line)
  return { type = type, line = line, }
end


T["identical strings"] = function()
  local result = child.lua_get [[M.diff(vim.split("hello", ""), vim.split("hello", ""))]]
  eq(result, {
    rec("=", "h"), rec("=", "e"), rec("=", "l"), rec("=", "l"), rec("=", "o"),
  })
end

T["completely different strings"] = function()
  local result = child.lua_get [[M.diff(vim.split("abc", ""), vim.split("xyz", ""))]]
  eq(result, {
    rec("-", "a"), rec("-", "b"), rec("+", "x"), rec("+", "y"), rec("-", "c"), rec("+", "z"),
  })
end

T["single character change"] = function()
  local result = child.lua_get [[M.diff(vim.split("hello", ""), vim.split("heala", ""))]]
  eq(result, {
    rec("=", "h"), rec("=", "e"), rec("-", "l"), rec("+", "a"),
    rec("=", "l"), rec("-", "o"), rec("+", "a"),
  })
end

T["addition at end"] = function()
  local result = child.lua_get [[M.diff(vim.split("cat", ""), vim.split("cats", ""))]]
  eq(result, {
    rec("=", "c"), rec("=", "a"), rec("=", "t"), rec("+", "s"),
  })
end

T["deletion at end"] = function()
  local result = child.lua_get [[M.diff(vim.split("cats", ""), vim.split("cat", ""))]]
  eq(result, {
    rec("=", "c"), rec("=", "a"), rec("=", "t"), rec("-", "s"),
  })
end

T["addition at beginning"] = function()
  local result = child.lua_get [[M.diff(vim.split("at", ""), vim.split("cat", ""))]]
  eq(result, {
    rec("+", "c"), rec("=", "a"), rec("=", "t"),
  })
end

T["deletion at beginning"] = function()
  local result = child.lua_get [[M.diff(vim.split("cat", ""), vim.split("at", ""))]]
  eq(result, {
    rec("-", "c"), rec("=", "a"), rec("=", "t"),
  })
end

T["empty to non-empty"] = function()
  local result = child.lua_get [[M.diff(vim.split("", ""), vim.split("abc", ""))]]
  eq(result, {
    rec("+", "a"), rec("+", "b"), rec("+", "c"),
  })
end

T["non-empty to empty"] = function()
  local result = child.lua_get [[M.diff(vim.split("abc", ""), vim.split("", ""))]]
  eq(result, {
    rec("-", "a"), rec("-", "b"), rec("-", "c"),
  })
end

T["both empty"] = function()
  local result = child.lua_get [[M.diff(vim.split("", ""), vim.split("", ""))]]
  eq(result, {})
end

T["insertion in middle"] = function()
  local result = child.lua_get [[M.diff(vim.split("ac", ""), vim.split("abc", ""))]]
  eq(result, {
    rec("=", "a"), rec("+", "b"), rec("=", "c"),
  })
end

T["deletion in middle"] = function()
  local result = child.lua_get [[M.diff(vim.split("abc", ""), vim.split("ac", ""))]]
  eq(result, {
    rec("=", "a"), rec("-", "b"), rec("=", "c"),
  })
end

T["multiple changes"] = function()
  local result = child.lua_get [[M.diff(vim.split("abcd", ""), vim.split("axcy", ""))]]
  eq(result, {
    rec("=", "a"), rec("-", "b"), rec("+", "x"), rec("=", "c"), rec("-", "d"), rec("+", "y"),
  })
end

T["reversed string"] = function()
  local result = child.lua_get [[M.diff(vim.split("abc", ""), vim.split("cba", ""))]]
  eq(result, {
    rec("-", "a"), rec("-", "b"), rec("=", "c"), rec("+", "b"), rec("+", "a"),
  })
end

T["longer to shorter"] = function()
  local result = child.lua_get [[M.diff(vim.split("abcdefgh", ""), vim.split("aceg", ""))]]
  eq(result, {
    rec("=", "a"), rec("-", "b"), rec("=", "c"), rec("-", "d"),
    rec("=", "e"), rec("-", "f"), rec("=", "g"), rec("-", "h"),
  })
end

T["shorter to longer"] = function()
  local result = child.lua_get [[M.diff(vim.split("aceg", ""), vim.split("abcdefgh", ""))]]
  eq(result, {
    rec("=", "a"), rec("+", "b"), rec("=", "c"), rec("+", "d"),
    rec("=", "e"), rec("+", "f"), rec("=", "g"), rec("+", "h"),
  })
end

T["single character"] = function()
  local result = child.lua_get [[M.diff(vim.split("a", ""), vim.split("b", ""))]]
  eq(result, {
    rec("-", "a"), rec("+", "b"),
  })
end

T["repeated characters"] = function()
  local result = child.lua_get [[M.diff(vim.split("aaa", ""), vim.split("aaaa", ""))]]
  eq(result, {
    rec("=", "a"), rec("=", "a"), rec("=", "a"), rec("+", "a"),
  })
end

return T
