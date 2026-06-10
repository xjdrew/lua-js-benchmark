-- FASTA benchmark - generate random DNA sequences
-- Uses linear congruential generator

local N = tonumber(arg and arg[1]) or 5000000
collectgarbage("collect")

local IM = 139968
local IA = 3877
local IC = 29573
local seed = 42

local function random(max)
    seed = (seed * IA + IC) % IM
    return max * seed / IM
end

local chars = "acgtBDHKMNRSVWY"
local probs = {
    0.27, 0.12, 0.12, 0.27,
    0.02, 0.02, 0.02, 0.02,
    0.02, 0.02, 0.02, 0.02,
    0.02, 0.02, 0.02
}

-- Build cumulative probabilities
local cumulative = {}
local cp = 0
for i = 1, #probs do
    cp = cp + probs[i]
    cumulative[i] = cp
end

local function select_char(r)
    for i = 1, #cumulative do
        if r < cumulative[i] then
            return chars:sub(i, i)
        end
    end
    return chars:sub(#chars, #chars)
end

local last_char
for i = 1, N do
    local r = random(1.0)
    last_char = select_char(r)
end

print(last_char)
print(seed)
