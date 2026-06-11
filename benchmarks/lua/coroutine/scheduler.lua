-- Coroutine scheduler benchmark
-- Create 100 coroutines, each counting from 0 to N/100, round-robin schedule

local N = tonumber(arg and arg[1]) or 5000000
-- collectgarbage("collect")

local num_coroutines = 100
local per_coroutine = math.floor(N / num_coroutines)

local function worker(limit)
    for i = 0, limit - 1 do
        coroutine.yield()
    end
end

-- Create coroutines
local coroutines = {}
for i = 1, num_coroutines do
    coroutines[i] = coroutine.create(function() worker(per_coroutine) end)
end

-- Round-robin scheduler
local total_yields = 0
local alive = num_coroutines
while alive > 0 do
    for i = 1, num_coroutines do
        local co = coroutines[i]
        if co then
            local ok, _ = coroutine.resume(co)
            if coroutine.status(co) == "dead" then
                coroutines[i] = nil
                alive = alive - 1
            else
                total_yields = total_yields + 1
            end
        end
    end
end

print(total_yields)
