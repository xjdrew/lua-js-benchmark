-- Closure benchmark
-- Tests closure creation, upvalue capture/mutation, and function composition
-- Classic funarg patterns from 1970s onward, common in production callback code

local N = tonumber(arg and arg[1]) or 10000000
collectgarbage("collect")

local function make_adder(k)
    return function(x) return x + k end
end

local function make_counter(init)
    local n = init
    return function(delta)
        n = n + delta
        return n
    end
end

local function compose(f, g)
    return function(x) return f(g(x)) end
end

local add1 = make_adder(1)
local add2 = make_adder(2)
local add3 = compose(add1, add2)

local counters = {}
for i = 1, 10 do
    counters[i] = make_counter(0)
end

local sum = 0
for i = 1, N do
    sum = sum + add3(i)

    local c = counters[(i % 10) + 1]
    sum = sum + c(1)

    if i % 10000 == 0 then
        local adder = make_adder(i)
        sum = sum + adder(i)
    end
end

print(sum)
