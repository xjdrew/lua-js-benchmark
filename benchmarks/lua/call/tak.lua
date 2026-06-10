-- Takeuchi function benchmark
-- Gabriel Benchmarks (1985), originally by Ikuo Takeuchi (1978)
-- Tests deeply recursive triple-branching function calls

local N = tonumber(arg and arg[1]) or 10
collectgarbage("collect")

local function tak(x, y, z)
    if y >= x then return z end
    return tak(tak(x - 1, y, z), tak(y - 1, z, x), tak(z - 1, x, y))
end

local result = tak(N * 3, N * 2, N)
print(result)
