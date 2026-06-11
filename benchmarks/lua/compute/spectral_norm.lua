-- The Computer Language Benchmarks Game
-- https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
-- Spectral norm benchmark

local sqrt = math.sqrt

local N = tonumber(arg and arg[1]) or 1000
-- collectgarbage("collect")

-- Element of the infinite matrix A
-- A(i,j) = 1 / ((i+j)(i+j+1)/2 + i + 1)  (0-indexed i,j)
local function A(i, j)
    local ij = i + j
    return 1.0 / (ij * (ij + 1) / 2 + i + 1)
end

-- Multiply v by A, store in Av
local function mul_Av(n, v, Av)
    for i = 0, n - 1 do
        local sum = 0.0
        for j = 0, n - 1 do
            sum = sum + A(i, j) * v[j]
        end
        Av[i] = sum
    end
end

-- Multiply v by A^T, store in Atv
local function mul_Atv(n, v, Atv)
    for i = 0, n - 1 do
        local sum = 0.0
        for j = 0, n - 1 do
            sum = sum + A(j, i) * v[j]
        end
        Atv[i] = sum
    end
end

-- Multiply v by A^T A, store in AtAv
local function mul_AtAv(n, v, AtAv, tmp)
    mul_Av(n, v, tmp)
    mul_Atv(n, tmp, AtAv)
end

-- Initialize vectors
local u = {}
local v = {}
local tmp = {}

for i = 0, N - 1 do
    u[i] = 1.0
    v[i] = 0.0
    tmp[i] = 0.0
end

-- Power iteration: 10 steps
for _ = 1, 10 do
    mul_AtAv(N, u, v, tmp)
    mul_AtAv(N, v, u, tmp)
end

local vBv = 0.0
local vv = 0.0
for i = 0, N - 1 do
    vBv = vBv + u[i] * v[i]
    vv  = vv  + v[i] * v[i]
end

print(string.format("%.9f", sqrt(vBv / vv)))
