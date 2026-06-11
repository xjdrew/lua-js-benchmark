-- The Computer Language Benchmarks Game
-- https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
-- Mandelbrot set benchmark
-- Compute NxN grid, count pixels inside the set

local N = tonumber(arg and arg[1]) or 1500
local MAX_ITER = 50
-- collectgarbage("collect")

local count = 0

for y = 0, N - 1 do
    local Ci = 2.0 * y / N - 1.0
    for x = 0, N - 1 do
        local Cr = 2.0 * x / N - 1.5
        local Zr, Zi = 0.0, 0.0
        local inside = true
        for _ = 1, MAX_ITER do
            local Tr = Zr * Zr - Zi * Zi + Cr
            local Ti = 2.0 * Zr * Zi + Ci
            Zr = Tr
            Zi = Ti
            if Zr * Zr + Zi * Zi > 4.0 then
                inside = false
                break
            end
        end
        if inside then
            count = count + 1
        end
    end
end

print(count)
