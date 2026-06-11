-- JSON parse benchmark
-- Build a JSON string of N objects and parse it with recursive descent parser

local N = tonumber(arg and arg[1]) or 100000
-- collectgarbage("collect")

-- Build JSON string
local parts = {}
parts[1] = "["
for i = 0, N - 1 do
    if i > 0 then
        parts[#parts + 1] = ","
    end
    parts[#parts + 1] = string.format('{"id":%d,"name":"item_%d","value":%s}',
        i, i, string.format("%.1f", i * 0.1))
end
parts[#parts + 1] = "]"
local json_str = table.concat(parts)

-- Simple recursive descent JSON parser
local pos

local parse_value -- forward declaration

local function skip_ws()
    while pos <= #json_str do
        local c = json_str:byte(pos)
        if c == 32 or c == 9 or c == 10 or c == 13 then
            pos = pos + 1
        else
            break
        end
    end
end

local function parse_string()
    pos = pos + 1 -- skip opening quote
    local start = pos
    while pos <= #json_str do
        local c = json_str:byte(pos)
        if c == 34 then -- closing quote
            local s = json_str:sub(start, pos - 1)
            pos = pos + 1
            return s
        elseif c == 92 then -- backslash
            pos = pos + 2
        else
            pos = pos + 1
        end
    end
    error("unterminated string")
end

local function parse_number()
    local start = pos
    while pos <= #json_str do
        local c = json_str:byte(pos)
        if c == 44 or c == 93 or c == 125 or c == 32 or c == 9 or c == 10 or c == 13 then
            break
        end
        pos = pos + 1
    end
    return tonumber(json_str:sub(start, pos - 1))
end

local function parse_array()
    pos = pos + 1 -- skip [
    local arr = {}
    skip_ws()
    if json_str:byte(pos) == 93 then -- empty array
        pos = pos + 1
        return arr
    end
    while true do
        skip_ws()
        arr[#arr + 1] = parse_value()
        skip_ws()
        local c = json_str:byte(pos)
        if c == 44 then -- comma
            pos = pos + 1
        elseif c == 93 then -- ]
            pos = pos + 1
            return arr
        else
            error("expected , or ] at pos " .. pos)
        end
    end
end

local function parse_object()
    pos = pos + 1 -- skip {
    local obj = {}
    skip_ws()
    if json_str:byte(pos) == 125 then -- empty object
        pos = pos + 1
        return obj
    end
    while true do
        skip_ws()
        local key = parse_string()
        skip_ws()
        pos = pos + 1 -- skip :
        skip_ws()
        obj[key] = parse_value()
        skip_ws()
        local c = json_str:byte(pos)
        if c == 44 then -- comma
            pos = pos + 1
        elseif c == 125 then -- }
            pos = pos + 1
            return obj
        else
            error("expected , or } at pos " .. pos)
        end
    end
end

parse_value = function()
    skip_ws()
    local c = json_str:byte(pos)
    if c == 34 then -- "
        return parse_string()
    elseif c == 91 then -- [
        return parse_array()
    elseif c == 123 then -- {
        return parse_object()
    elseif c == 116 then -- true
        pos = pos + 4
        return true
    elseif c == 102 then -- false
        pos = pos + 5
        return false
    elseif c == 110 then -- null
        pos = pos + 4
        return nil
    else
        return parse_number()
    end
end

-- Parse
pos = 1
local data = parse_value()

-- Sum all id fields
local id_sum = 0
local count = 0
for i = 1, #data do
    id_sum = id_sum + data[i].id
    count = count + 1
end

print(id_sum)
print(count)
