-- String concatenation benchmark
-- Concatenate "x" N times using table.concat

local N = tonumber(arg and arg[1]) or 100000

local t = {}
for i = 1, N do
    t[i] = "x"
end
local result = table.concat(t)

print(#result)
