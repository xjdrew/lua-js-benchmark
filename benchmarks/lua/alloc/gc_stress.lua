-- GC stress benchmark
-- Mixed short/long lived allocations to test garbage collector throughput
-- Lua 5.5's incremental major GC should excel here

local N = tonumber(arg and arg[1]) or 2000000
-- collectgarbage("collect")

-- Long-lived data structure (survives entire benchmark)
local registry = {}
local registry_size = 1000

for i = 1, registry_size do
    registry[i] = { id = i, data = {}, refs = {} }
    for j = 1, 10 do
        registry[i].data[j] = j * i
    end
end

local sum = 0
local temp_pool = {}

for i = 1, N do
    -- Short-lived: create small objects that die immediately
    local obj = { x = i, y = i * 2, z = i * 3 }
    sum = sum + obj.x + obj.y + obj.z

    -- Medium-lived: rotate through a pool
    local slot = (i % 100) + 1
    temp_pool[slot] = { value = i, prev = temp_pool[slot] }

    -- Periodically update long-lived structures
    if i % 1000 == 0 then
        local idx = (i / 1000 % registry_size) + 1
        local entry = registry[idx]
        entry.refs[#entry.refs + 1] = { ts = i, val = sum }
        -- Trim to prevent unbounded growth
        if #entry.refs > 10 then
            entry.refs = { entry.refs[#entry.refs] }
        end
    end
end

-- Verify long-lived data survived
local reg_sum = 0
for i = 1, registry_size do
    for j = 1, 10 do
        reg_sum = reg_sum + registry[i].data[j]
    end
end

print(sum)
print(reg_sum)
