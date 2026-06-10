-- N-queens benchmark
-- Count all solutions to the N-queens problem

local N = tonumber(arg and arg[1]) or 12

local count = 0
local cols = {}
local diag1 = {}
local diag2 = {}

local function solve(row)
    if row > N then
        count = count + 1
        return
    end
    for col = 1, N do
        local d1 = row - col + N
        local d2 = row + col
        if not cols[col] and not diag1[d1] and not diag2[d2] then
            cols[col] = true
            diag1[d1] = true
            diag2[d2] = true
            solve(row + 1)
            cols[col] = nil
            diag1[d1] = nil
            diag2[d2] = nil
        end
    end
end

solve(1)
print(count .. " solutions for " .. N .. "-queens")
