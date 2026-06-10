-- Ackermann function benchmark

local M = tonumber(arg and arg[1]) or 10
collectgarbage("collect")

local function ack(m, n)
    if m == 0 then
        return n + 1
    elseif n == 0 then
        return ack(m - 1, 1)
    else
        return ack(m - 1, ack(m, n - 1))
    end
end

local result = ack(3, M)
print("Ack(3," .. M .. "): " .. result)
