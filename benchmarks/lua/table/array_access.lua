-- Array access benchmark
-- Create array, sum elements, reverse in-place, sum again

local N = tonumber(arg and arg[1]) or 20000000
collectgarbage("collect")

local arr = {}
for i = 1, N do
    arr[i] = i % 100
end

-- First sum
local sum1 = 0
for i = 1, N do
    sum1 = sum1 + arr[i]
end

-- Reverse in-place
local half = math.floor(N / 2)
for i = 1, half do
    local j = N - i + 1
    arr[i], arr[j] = arr[j], arr[i]
end

-- Second sum
local sum2 = 0
for i = 1, N do
    sum2 = sum2 + arr[i]
end

print(sum1)
print(sum2)
