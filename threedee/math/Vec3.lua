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

---@param x? number
---@param y? number
---@param z? number
---@return Vec3
function Vec3:new(x, y, z)
    return setmetatable({x or 0, y or 0, z or 0}, self)
end

---@return Vec3
function Vec3:clone()
    return Vec3:new(self[1], self[2], self[3])
end

---@param source Vec3
---@return self
function Vec3:copy(source)
    self[1], self[2], self[3] = source[1], source[2], source[3]
    return self
end

---@param x number
---@param y number
---@param z number
---@return self
function Vec3:set(x, y, z)
    self[1], self[2], self[3] = x, y, z
    return self
end

---@param m Mat3
---@param i 1|2|3
---@return self
function Vec3:setFromMatRow(m, i)
    self[1], self[2], self[3] = m[i], m[3+i], m[6+i]
    return self
end

---@param m Mat3
---@param i 1|2|3
---@return self
function Vec3:setFromMatCol(m, i)
    self[1], self[2], self[3] = m[i*3-2], m[i*3-1], m[i*3]
    return self
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
---@return self
function Vec3:cross(other)
    return self:set(
        self[2] * other[3] - self[3] * other[2],
        self[3] * other[1] - self[1] * other[3],
        self[1] * other[2] - self[2] * other[1]
    )
end

---Applies a quaternion rotation to `self`.
---@param quat Quat
---@return self
function Vec3:applyQuat(quat)
    -- https://gamedev.stackexchange.com/a/50545
    local u = Vec3:new(quat[1], quat[2], quat[3])
    local s = quat[4]
    local uCrossV = u:clone():cross(self)
    local uDotV = u:dot(self)
    local uDotU = u:lengthSquared()
    return self:scale(s*s - uDotU):add(u:scale(2 * uDotV)):add(uCrossV:scale(2 * s))
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