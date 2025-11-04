local M = {}

--- @param tbl_a string[]
--- @param tbl_b string[]
M.diff = function(tbl_a, tbl_b)
  local memo = {}

  for i = 1, #tbl_a do
    memo[i] = {}
    for _ = 1, #tbl_b do
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

    if idx_a == #tbl_a_inner or idx_b == #tbl_b_inner then return 0 end

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
end

-- M.diff(vim.split("hello", ""), vim.split("heala", ""))

return M
