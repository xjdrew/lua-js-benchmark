-- The Computer Language Benchmarks Game
-- https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
-- Binary trees benchmark

local N = tonumber(arg and arg[1]) or 15
-- collectgarbage("collect")

local function make(depth)
    if depth == 0 then
        return { 1 }
    end
    depth = depth - 1
    return { make(depth), make(depth) }
end

local function check(node)
    if node[2] then
        return 1 + check(node[1]) + check(node[2])
    end
    return 1
end

local min_depth = 4
local max_depth = N
if min_depth + 2 > max_depth then
    max_depth = min_depth + 2
end

local stretch_depth = max_depth + 1
io.write(string.format("stretch tree of depth %d\t check: %d\n",
    stretch_depth, check(make(stretch_depth))))

local long_lived = make(max_depth)

for depth = min_depth, max_depth, 2 do
    local iterations = 2 ^ (max_depth - depth + min_depth)
    local sum = 0
    for i = 1, iterations do
        sum = sum + check(make(depth))
    end
    io.write(string.format("%d\t trees of depth %d\t check: %d\n",
        iterations, depth, sum))
end

io.write(string.format("long lived tree of depth %d\t check: %d\n",
    max_depth, check(long_lived)))
