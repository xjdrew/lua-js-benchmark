-- Method dispatch benchmark
-- Tests metatable-based OOP: class creation, object instantiation, method calls
-- Representative of production Lua patterns (OpenResty, game scripting)

local N = tonumber(arg and arg[1]) or 5000000
-- collectgarbage("collect")

-- Base class via metatables
local Animal = {}
Animal.__index = Animal

function Animal.new(name, legs, sound)
    local self = setmetatable({}, Animal)
    self.name = name
    self.legs = legs
    self.sound = sound
    self.energy = 100
    return self
end

function Animal:speak()
    return self.sound
end

function Animal:move(dist)
    self.energy = self.energy - dist
    return self.energy
end

function Animal:rest(amount)
    self.energy = self.energy + amount
    return self.energy
end

-- Derived class
local Dog = setmetatable({}, { __index = Animal })
Dog.__index = Dog

function Dog.new(name)
    local self = Animal.new(name, 4, "woof")
    return setmetatable(self, Dog)
end

function Dog:fetch(dist)
    self:move(dist)
    self:move(dist)
    return self.energy
end

-- Another derived class
local Bird = setmetatable({}, { __index = Animal })
Bird.__index = Bird

function Bird.new(name)
    local self = Animal.new(name, 2, "tweet")
    return setmetatable(self, Bird)
end

function Bird:fly(dist)
    self:move(dist * 2)
    return self.energy
end

-- Create objects and call methods polymorphically
local animals = {
    Dog.new("Rex"),
    Bird.new("Tweety"),
    Dog.new("Buddy"),
    Bird.new("Eagle"),
    Animal.new("Cat", 4, "meow"),
}

local total = 0
local nanimals = #animals

for i = 1, N do
    local a = animals[(i % nanimals) + 1]
    a:rest(10)
    a:move(3)
    total = total + a.energy
    a:speak()
end

print(total)
