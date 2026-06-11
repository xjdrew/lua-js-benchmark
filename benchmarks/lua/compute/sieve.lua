-- Sieve of Eratosthenes benchmark
-- Byte Magazine "Byte Sieve" (1981), one of the earliest cross-language benchmarks
-- Tests conditional loops with stride-based array writes

local N = tonumber(arg and arg[1]) or 2000000
-- collectgarbage("collect")

local R = 10
local count

for _ = 1, R do
    local flags = {}
    for i = 2, N do
        flags[i] = true
    end

    count = 0
    for i = 2, N do
        if flags[i] then
            count = count + 1
            if i * i <= N then
                for j = i * i, N, i do
                    flags[j] = false
                end
            end
        end
    end
end

print(count)
