-- The Computer Language Benchmarks Game
-- https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
-- Fannkuch-redux benchmark

local N = tonumber(arg and arg[1]) or 10

local perm = {}
local perm1 = {}
local count = {}
local maxflips = 0
local checksum = 0

-- Initialize
for i = 0, N - 1 do
    perm1[i] = i
end

local r = N

local function flip_count()
    -- Copy perm1 into perm
    for i = 0, N - 1 do
        perm[i] = perm1[i]
    end

    local flips = 0
    local first = perm[0]
    while first ~= 0 do
        -- Reverse perm[0..first]
        local lo, hi = 0, first
        while lo < hi do
            perm[lo], perm[hi] = perm[hi], perm[lo]
            lo = lo + 1
            hi = hi - 1
        end
        flips = flips + 1
        first = perm[0]
    end
    return flips
end

local perm_count = 0

while true do
    -- Use current permutation
    while r ~= 1 do
        count[r - 1] = r
        r = r - 1
    end

    local flips = flip_count()
    if flips > maxflips then
        maxflips = flips
    end
    if perm_count % 2 == 0 then
        checksum = checksum + flips
    else
        checksum = checksum - flips
    end
    perm_count = perm_count + 1

    -- Generate next permutation
    local done = false
    while true do
        if r == N then
            done = true
            break
        end

        -- Rotate perm1[0..r] left by one
        local perm0 = perm1[0]
        for i = 0, r - 1 do
            perm1[i] = perm1[i + 1]
        end
        perm1[r] = perm0

        count[r] = count[r] - 1
        if count[r] > 0 then
            break
        end
        r = r + 1
    end

    if done then
        break
    end
end

io.write(string.format("%d\nPfannkuchen(%d) = %d\n", checksum, N, maxflips))
