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
--- @param linenr number
--- @return DiffRecord
local function rec(type, line, linenr)
  return { type = type, line = line, linenr = linenr, }
end


T["identical strings"] = function()
  local result = child.lua_get [[M.diff(vim.split("hello", ""), vim.split("hello", ""))]]
  eq(result, {
    rec("=", "h", 1), rec("=", "e", 2), rec("=", "l", 3), rec("=", "l", 4), rec("=", "o", 5),
  })
end

T["completely different strings"] = function()
  local result = child.lua_get [[M.diff(vim.split("abc", ""), vim.split("xyz", ""))]]
  eq(result, {
    rec("-", "a", 1), rec("-", "b", 2), rec("+", "x", 1), rec("+", "y", 2), rec("-", "c", 3), rec("+", "z", 3),
  })
end

T["single character change"] = function()
  local result = child.lua_get [[M.diff(vim.split("hello", ""), vim.split("heala", ""))]]
  eq(result, {
    rec("=", "h", 1), rec("=", "e", 2), rec("-", "l", 3), rec("+", "a", 3),
    rec("=", "l", 4), rec("-", "o", 5), rec("+", "a", 5),
  })
end

T["addition at end"] = function()
  local result = child.lua_get [[M.diff(vim.split("cat", ""), vim.split("cats", ""))]]
  eq(result, {
    rec("=", "c", 1), rec("=", "a", 2), rec("=", "t", 3), rec("+", "s", 4),
  })
end

T["deletion at end"] = function()
  local result = child.lua_get [[M.diff(vim.split("cats", ""), vim.split("cat", ""))]]
  eq(result, {
    rec("=", "c", 1), rec("=", "a", 2), rec("=", "t", 3), rec("-", "s", 4),
  })
end

T["addition at beginning"] = function()
  local result = child.lua_get [[M.diff(vim.split("at", ""), vim.split("cat", ""))]]
  eq(result, {
    rec("+", "c", 1), rec("=", "a", 1), rec("=", "t", 2),
  })
end

T["deletion at beginning"] = function()
  local result = child.lua_get [[M.diff(vim.split("cat", ""), vim.split("at", ""))]]
  eq(result, {
    rec("-", "c", 1), rec("=", "a", 2), rec("=", "t", 3),
  })
end

T["empty to non-empty"] = function()
  local result = child.lua_get [[M.diff(vim.split("", ""), vim.split("abc", ""))]]
  eq(result, {
    rec("+", "a", 1), rec("+", "b", 2), rec("+", "c", 3),
  })
end

T["non-empty to empty"] = function()
  local result = child.lua_get [[M.diff(vim.split("abc", ""), vim.split("", ""))]]
  eq(result, {
    rec("-", "a", 1), rec("-", "b", 2), rec("-", "c", 3),
  })
end

T["both empty"] = function()
  local result = child.lua_get [[M.diff(vim.split("", ""), vim.split("", ""))]]
  eq(result, {})
end

T["insertion in middle"] = function()
  local result = child.lua_get [[M.diff(vim.split("ac", ""), vim.split("abc", ""))]]
  eq(result, {
    rec("=", "a", 1), rec("+", "b", 2), rec("=", "c", 2),
  })
end

T["deletion in middle"] = function()
  local result = child.lua_get [[M.diff(vim.split("abc", ""), vim.split("ac", ""))]]
  eq(result, {
    rec("=", "a", 1), rec("-", "b", 2), rec("=", "c", 3),
  })
end

T["multiple changes"] = function()
  local result = child.lua_get [[M.diff(vim.split("abcd", ""), vim.split("axcy", ""))]]
  eq(result, {
    rec("=", "a", 1), rec("-", "b", 2), rec("+", "x", 2), rec("=", "c", 3), rec("-", "d", 4), rec("+", "y", 4),
  })
end

T["reversed string"] = function()
  local result = child.lua_get [[M.diff(vim.split("abc", ""), vim.split("cba", ""))]]
  eq(result, {
    rec("-", "a", 1), rec("-", "b", 2), rec("=", "c", 3), rec("+", "b", 2), rec("+", "a", 3),
  })
end

T["longer to shorter"] = function()
  local result = child.lua_get [[M.diff(vim.split("abcdefgh", ""), vim.split("aceg", ""))]]
  eq(result, {
    rec("=", "a", 1), rec("-", "b", 2), rec("=", "c", 3), rec("-", "d", 4),
    rec("=", "e", 5), rec("-", "f", 6), rec("=", "g", 7), rec("-", "h", 8),
  })
end

T["shorter to longer"] = function()
  local result = child.lua_get [[M.diff(vim.split("aceg", ""), vim.split("abcdefgh", ""))]]
  eq(result, {
    rec("=", "a", 1), rec("+", "b", 2), rec("=", "c", 2), rec("+", "d", 4),
    rec("=", "e", 3), rec("+", "f", 6), rec("=", "g", 4), rec("+", "h", 8),
  })
end

T["single character"] = function()
  local result = child.lua_get [[M.diff(vim.split("a", ""), vim.split("b", ""))]]
  eq(result, {
    rec("-", "a", 1), rec("+", "b", 1),
  })
end

T["repeated characters"] = function()
  local result = child.lua_get [[M.diff(vim.split("aaa", ""), vim.split("aaaa", ""))]]
  eq(result, {
    rec("=", "a", 1), rec("=", "a", 2), rec("=", "a", 3), rec("+", "a", 4),
  })
end

return T
