-- Matrix multiplication benchmark
-- Multiply two NxN matrices using table-of-tables representation
-- Tests nested table access + numerical computation

local N = tonumber(arg and arg[1]) or 200
collectgarbage("collect")

local function make_matrix(rows, cols, init_fn)
    local m = {}
    for i = 1, rows do
        m[i] = {}
        for j = 1, cols do
            m[i][j] = init_fn(i, j)
        end
    end
    return m
end

local function multiply(a, b, n)
    local c = {}
    for i = 1, n do
        c[i] = {}
        for j = 1, n do
            local sum = 0.0
            for k = 1, n do
                sum = sum + a[i][k] * b[k][j]
            end
            c[i][j] = sum
        end
    end
    return c
end

-- Initialize matrices
local A = make_matrix(N, N, function(i, j) return (i + j - 1) % 7 + 1.0 end)
local B = make_matrix(N, N, function(i, j) return (i * j) % 11 + 1.0 end)

-- Multiply 3 times: C = A*B, D = C*B, E = D*B
local C = multiply(A, B, N)
local D = multiply(C, B, N)
local E = multiply(D, B, N)

-- Checksum: sum of corner elements
local checksum = E[1][1] + E[1][N] + E[N][1] + E[N][N]
print(string.format("%.6f", checksum))
