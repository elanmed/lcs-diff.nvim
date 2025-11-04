# `lcs-diff.nvim`

A longest common subsequence (LCS) file-diff implementation using Neovim's lua utility functions.

### API
```lua
--- @alias DiffRecordType "+"|"-"|"="
--- @alias DiffRecord { type: DiffRecordType, line: string, linenr: number }

--- @param tbl_a string[]
--- @param tbl_b string[]
--- @return DiffRecord[]
M.diff = function(tbl_a, tbl_b) end
```
