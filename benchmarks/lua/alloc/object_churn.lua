-- Object churn benchmark
-- Create N small tables with 3 fields and sum all values

local N = tonumber(arg and arg[1]) or 1000000

local sum = 0
for i = 0, N - 1 do
    local obj = { x = i, y = i * 2, z = i * 3 }
    sum = sum + obj.x + obj.y + obj.z
end

print(sum)
