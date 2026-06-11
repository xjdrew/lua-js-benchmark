-- Mixed table operations benchmark
-- String key insert, nested lookup, iteration, delete, merge
-- Representative of config/data processing patterns

local N = tonumber(arg and arg[1]) or 500000
-- collectgarbage("collect")

-- Phase 1: Insert key-value pairs with string keys
local data = {}
for i = 1, N do
    data["item_" .. i] = { id = i, value = i * 3, tags = { "a", "b" } }
end

-- Phase 2: Nested lookups
local lookup_sum = 0
for i = 1, N do
    local entry = data["item_" .. i]
    if entry then
        lookup_sum = lookup_sum + entry.value + entry.id
    end
end

-- Phase 3: Iterate and accumulate
local iter_sum = 0
local count = 0
for k, v in pairs(data) do
    iter_sum = iter_sum + v.value
    count = count + 1
end

-- Phase 4: Delete half the entries
for i = 1, N, 2 do
    data["item_" .. i] = nil
end

-- Phase 5: Merge remaining into new table
local merged = {}
local merge_count = 0
for k, v in pairs(data) do
    merged[k] = v
    merge_count = merge_count + 1
end

print(lookup_sum)
print(iter_sum)
print(count)
print(merge_count)
