-- Table insert benchmark
-- Insert N key-value pairs, then sum all values

local N = tonumber(arg and arg[1]) or 1000000

local t = {}
for i = 1, N do
    t["key_" .. i] = i
end

local sum = 0
for _, v in pairs(t) do
    sum = sum + v
end

print(sum)
