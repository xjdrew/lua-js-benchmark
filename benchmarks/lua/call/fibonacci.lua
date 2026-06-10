-- Naive recursive Fibonacci benchmark

local N = tonumber(arg and arg[1]) or 38
collectgarbage("collect")

local function fib(n)
    if n < 2 then
        return n
    end
    return fib(n - 1) + fib(n - 2)
end

local result = fib(N)
print("fib(" .. N .. ") = " .. result)
