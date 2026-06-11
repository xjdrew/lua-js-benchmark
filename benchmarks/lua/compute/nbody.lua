-- The Computer Language Benchmarks Game
-- https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
-- N-body simulation benchmark

local sqrt = math.sqrt
local PI = 3.141592653589793
local SOLAR_MASS = 4 * PI * PI
local DAYS_PER_YEAR = 365.24

local bodies = {
    -- Sun
    { x = 0.0, y = 0.0, z = 0.0,
      vx = 0.0, vy = 0.0, vz = 0.0,
      mass = SOLAR_MASS },
    -- Jupiter
    { x =  4.84143144246472090e+00,
      y = -1.16032004402742839e+00,
      z = -1.03622044471123109e-01,
      vx =  1.66007664274403694e-03 * DAYS_PER_YEAR,
      vy =  7.69901118419740425e-03 * DAYS_PER_YEAR,
      vz = -6.90460016972063023e-05 * DAYS_PER_YEAR,
      mass =  9.54791938424326609e-04 * SOLAR_MASS },
    -- Saturn
    { x =  8.34336671824457987e+00,
      y =  4.12479856412430479e+00,
      z = -4.03523417114321381e-01,
      vx = -2.76742510726862411e-03 * DAYS_PER_YEAR,
      vy =  4.99852801234917238e-03 * DAYS_PER_YEAR,
      vz =  2.30417297573763929e-05 * DAYS_PER_YEAR,
      mass =  2.85885980666130812e-04 * SOLAR_MASS },
    -- Uranus
    { x =  1.28943695621391310e+01,
      y = -1.51111514016986312e+01,
      z = -2.23307578892655734e-01,
      vx =  2.96460137564761618e-03 * DAYS_PER_YEAR,
      vy =  2.37847173959480950e-03 * DAYS_PER_YEAR,
      vz = -2.96589568540237556e-05 * DAYS_PER_YEAR,
      mass =  4.36624404335156298e-05 * SOLAR_MASS },
    -- Neptune
    { x =  1.53796971148509165e+01,
      y = -2.59193146099879641e+01,
      z =  1.79258772950371181e-01,
      vx =  2.68067772490389322e-03 * DAYS_PER_YEAR,
      vy =  1.62824170038242295e-03 * DAYS_PER_YEAR,
      vz = -9.51592254519715870e-05 * DAYS_PER_YEAR,
      mass =  5.15138902046611451e-05 * SOLAR_MASS },
}

local nbodies = #bodies

-- Offset momentum so the system's center of mass is stationary
local function offset_momentum()
    local px, py, pz = 0.0, 0.0, 0.0
    for i = 1, nbodies do
        local b = bodies[i]
        px = px + b.vx * b.mass
        py = py + b.vy * b.mass
        pz = pz + b.vz * b.mass
    end
    local sun = bodies[1]
    sun.vx = -px / SOLAR_MASS
    sun.vy = -py / SOLAR_MASS
    sun.vz = -pz / SOLAR_MASS
end

local function energy()
    local e = 0.0
    for i = 1, nbodies do
        local bi = bodies[i]
        e = e + 0.5 * bi.mass * (bi.vx * bi.vx + bi.vy * bi.vy + bi.vz * bi.vz)
        for j = i + 1, nbodies do
            local bj = bodies[j]
            local dx = bi.x - bj.x
            local dy = bi.y - bj.y
            local dz = bi.z - bj.z
            local dist = sqrt(dx * dx + dy * dy + dz * dz)
            e = e - (bi.mass * bj.mass) / dist
        end
    end
    return e
end

local function advance(dt)
    for i = 1, nbodies do
        local bi = bodies[i]
        local bix, biy, biz = bi.x, bi.y, bi.z
        local bivx, bivy, bivz = bi.vx, bi.vy, bi.vz
        local bimass = bi.mass
        for j = i + 1, nbodies do
            local bj = bodies[j]
            local dx = bix - bj.x
            local dy = biy - bj.y
            local dz = biz - bj.z
            local dsq = dx * dx + dy * dy + dz * dz
            local dist = sqrt(dsq)
            local mag = dt / (dsq * dist)
            local bjmass = bj.mass
            bivx = bivx - dx * bjmass * mag
            bivy = bivy - dy * bjmass * mag
            bivz = bivz - dz * bjmass * mag
            bj.vx = bj.vx + dx * bimass * mag
            bj.vy = bj.vy + dy * bimass * mag
            bj.vz = bj.vz + dz * bimass * mag
        end
        bi.vx = bivx
        bi.vy = bivy
        bi.vz = bivz
        bi.x = bix + dt * bivx
        bi.y = biy + dt * bivy
        bi.z = biz + dt * bivz
    end
end

local N = tonumber(arg and arg[1]) or 500000
-- collectgarbage("collect")

offset_momentum()
print(string.format("%.9f", energy()))

for _ = 1, N do
    advance(0.01)
end

print(string.format("%.9f", energy()))
