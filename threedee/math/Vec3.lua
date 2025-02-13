local class = require "threedee.class"

local sqrt = math.sqrt

---@class Vec3
---@field [1] number
---@field [2] number
---@field [3] number
---@operator add(Vec3): Vec3
---@operator sub(Vec3): Vec3
---@operator mul(Vec3): Vec3
---@operator div(Vec3): Vec3
---@operator unm(Vec3): Vec3
local Vec3 = class('Vec3')

---@param x number
---@param y number
---@param z number
---@return Vec3
function Vec3:new(x, y, z)
    return setmetatable({x, y, z}, self)
end

---@return Vec3
function Vec3:clone()
    return Vec3:new(self[1], self[2], self[3])
end

---@param other Vec3
---@return self
function Vec3:add(other)
    self[1] = self[1] + other[1]
    self[2] = self[2] + other[2]
    self[3] = self[3] + other[3]
    return self
end

---@param other Vec3
---@return self
function Vec3:sub(other)
    self[1] = self[1] - other[1]
    self[2] = self[2] - other[2]
    self[3] = self[3] - other[3]
    return self
end

---@param other Vec3
---@return self
function Vec3:mul(other)
    self[1] = self[1] * other[1]
    self[2] = self[2] * other[2]
    self[3] = self[3] * other[3]
    return self
end

---@param other Vec3
---@return self
function Vec3:div(other)
    self[1] = self[1] / other[1]
    self[2] = self[2] / other[2]
    self[3] = self[3] / other[3]
    return self
end

---@return self
function Vec3:neg()
    self[1] = -self[1]
    self[2] = -self[2]
    self[3] = -self[3]
    return self
end

---@param r number
---@return self
function Vec3:scale(r)
    self[1] = self[1] * r
    self[2] = self[2] * r
    self[3] = self[3] * r
    return self
end

---@return number
function Vec3:lengthSquared()
    return self[1] * self[1] + self[2] * self[2] + self[3] * self[3]
end

---@return number
function Vec3:length()
    return sqrt(self:lengthSquared())
end

---@return self
function Vec3:normalize()
    local len = self:length()
    if len ~= 0 and len ~= 1 then
        self:scale(1 / len)
    end
    return self
end

---@param other Vec3
---@return number
function Vec3:dot(other)
    return self[1] * other[1] + self[2] * other[2] + self[3] * other[3]
end

---@param other Vec3
---@return Vec3
function Vec3:cross(other)
    return Vec3:new(
        self[2] * other[3] - self[3] * other[2],
        self[3] * other[1] - self[1] * other[3],
        self[1] * other[2] - self[2] * other[1]
    )
end

---@param a Vec3
---@param b Vec3
---@return Vec3
function Vec3.__add(a, b)
    return a:clone():add(b)
end

---@param a Vec3
---@param b Vec3
---@return Vec3
function Vec3.__sub(a, b)
    return a:clone():sub(b)
end

---@param a Vec3
---@param b Vec3
---@return Vec3
function Vec3.__mul(a, b)
    return a:clone():mul(b)
end

---@param a Vec3
---@param b Vec3
---@return Vec3
function Vec3.__div(a, b)
    return a:clone():div(b)
end

---@param a Vec3
---@return Vec3
function Vec3.__unm(a)
    return a:clone():neg()
end

function Vec3:__tostring()
    return 'vec3(' .. self[1] .. ',' .. self[2] .. ',' .. self[3] .. ')'
end

return Vec3