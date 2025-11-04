local M = {}

--- @alias DiffRecordType "+"|"-"|"="
--- @alias DiffRecord { type: DiffRecordType, line: string }

--- @param tbl_a string[]
--- @param tbl_b string[]
--- @return DiffRecord[]
M.diff = function(tbl_a, tbl_b)
  local memo = {}

  for i = 1, #tbl_a + 1 do
    memo[i] = {}
    for _ = 1, #tbl_b + 1 do
      table.insert(memo[i], -1)
    end
  end

  local populate_memo

  --- @param tbl_a_inner string[]
  --- @param tbl_b_inner string[]
  --- @param idx_a number
  --- @param idx_b number
  populate_memo = function(tbl_a_inner, tbl_b_inner, idx_a, idx_b)
    if memo[idx_a][idx_b] ~= -1 then return memo[idx_a][idx_b] end

    if idx_a > #tbl_a_inner or idx_b > #tbl_b_inner then return 0 end

    if tbl_a_inner[idx_a] == tbl_b_inner[idx_b] then
      memo[idx_a][idx_b] = 1 + populate_memo(tbl_a_inner, tbl_b_inner, idx_a + 1, idx_b + 1)
    else
      memo[idx_a][idx_b] = math.max(
        populate_memo(tbl_a_inner, tbl_b_inner, idx_a + 1, idx_b),
        populate_memo(tbl_a_inner, tbl_b_inner, idx_a, idx_b + 1)
      )
    end

    return memo[idx_a][idx_b]
  end
  populate_memo(tbl_a, tbl_b, 1, 1)

  --- @type DiffRecord[]
  local records = {}

  local ptr_a = 1
  local ptr_b = 1
  while ptr_a <= #tbl_a and ptr_b <= #tbl_b do
    if tbl_a[ptr_a] == tbl_b[ptr_b] then
      table.insert(records, { type = "=", line = tbl_a[ptr_a], })
      ptr_a = ptr_a + 1
      ptr_b = ptr_b + 1
    else
      local change_a_len = memo[ptr_a + 1][ptr_b]
      local change_b_len = memo[ptr_a][ptr_b + 1]
      if change_a_len >= change_b_len then
        table.insert(records, { type = "-", line = tbl_a[ptr_a], })
        ptr_a = ptr_a + 1
      else
        table.insert(records, { type = "+", line = tbl_b[ptr_b], })
        ptr_b = ptr_b + 1
      end
    end
  end

  while ptr_a <= #tbl_a do
    table.insert(records, { type = "-", line = tbl_a[ptr_a], })
    ptr_a = ptr_a + 1
  end

  while ptr_b <= #tbl_b do
    table.insert(records, { type = "+", line = tbl_b[ptr_b], })
    ptr_b = ptr_b + 1
  end

  return records
end

return M
