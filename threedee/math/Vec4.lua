local class = require "threedee.class"

local sqrt = math.sqrt

---A 4D vector.
---@class Vec4
---@field [1] number X component.
---@field [2] number Y component.
---@field [3] number Z component.
---@field [4] number W component.
---@operator add(Vec4): Vec4
---@operator sub(Vec4): Vec4
---@operator mul(Vec4): Vec4
---@operator div(Vec4): Vec4
---@operator unm(Vec4): Vec4
local Vec4 = class('Vec4')

---Creates a new Vec4.
---If no arguments are given, `(0, 0, 0, 0)` is returned.
---@param x? number
---@param y? number
---@param z? number
---@param w? number
---@return Vec4
function Vec4:new(x, y, z, w)
    return setmetatable({x or 0, y or 0, z or 0, w or 0}, self)
end

---Returns a copy of `self`.
---@return Vec4
function Vec4:clone()
    return Vec4:new(self[1], self[2], self[3], self[4])
end

---Copies the value of `source` to `self`.
---@param source Vec4
---@return self
function Vec4:copy(source)
    self[1], self[2], self[3], self[4] = source[1], source[2], source[3], source[4]
    return self
end

---Sets the components of `self`.
---@param x number
---@param y number
---@param z number
---@param w number
---@return self
function Vec4:set(x, y, z, w)
    self[1], self[2], self[3], self[4] = x, y, z, w
    return self
end

---Sets `self` as the `i`th row vector of matrix `m`.
---@param m Mat4
---@param i 1|2|3|4
---@return self
function Vec4:setFromMatRow(m, i)
    self[1], self[2], self[3], self[4] = m[i], m[4+i], m[8+i], m[12+i]
    return self
end

---Sets `self` as the `i`th column vector of matrix `m`.
---@param m Mat4
---@param i 1|2|3|4
---@return self
function Vec4:setFromMatCol(m, i)
    self[1], self[2], self[3], self[4] = m[i*4-3], m[i*4-2], m[i*4-1], m[i*4]
    return self
end

---Sets `self` to the result of `self + other`.
---@param other Vec4
---@return self
function Vec4:add(other)
    self[1] = self[1] + other[1]
    self[2] = self[2] + other[2]
    self[3] = self[3] + other[3]
    self[4] = self[4] + other[4]
    return self
end

---Sets `self` to the result of `self - other`.
---@param other Vec4
---@return self
function Vec4:sub(other)
    self[1] = self[1] - other[1]
    self[2] = self[2] - other[2]
    self[3] = self[3] - other[3]
    self[4] = self[4] - other[4]
    return self
end

---Sets `self` to the result of an element-wise multiplication between
---`self` and `other`.
---@param other Vec4
---@return self
function Vec4:mul(other)
    self[1] = self[1] * other[1]
    self[2] = self[2] * other[2]
    self[3] = self[3] * other[3]
    self[4] = self[4] * other[4]
    return self
end

---Sets `self` to the result of an element-wise division between
---`self` and `other`.
---@param other Vec4
---@return self
function Vec4:div(other)
    self[1] = self[1] / other[1]
    self[2] = self[2] / other[2]
    self[3] = self[3] / other[3]
    self[4] = self[4] / other[4]
    return self
end

---Sets `self` to the value of `-self`.
---@return self
function Vec4:neg()
    self[1] = -self[1]
    self[2] = -self[2]
    self[3] = -self[3]
    self[4] = -self[4]
    return self
end

---Scales `self` by the scalar `r`.
---@param r number
---@return self
function Vec4:scale(r)
    self[1] = self[1] * r
    self[2] = self[2] * r
    self[3] = self[3] * r
    self[4] = self[4] * r
    return self
end

---Returns the squared length of `self`.
---@return number
function Vec4:lengthSquared()
    return (
        self[1] * self[1] +
        self[2] * self[2] +
        self[3] * self[3] +
        self[4] * self[4]
    )
end

---Returns the length of `self`.
---@return number
function Vec4:length()
    return sqrt(self:lengthSquared())
end

---Normalizes the length of `self`. If `self` has length zero, this does nothing.
---@return self
function Vec4:normalize()
    local len = self:length()
    if len ~= 0 and len ~= 1 then
        self:scale(1 / len)
    end
    return self
end

---Returns the dot product between `self` and `other`.
---@param other Vec4
---@return number
function Vec4:dot(other)
    return (
        self[1] * other[1] +
        self[2] * other[2] +
        self[3] * other[3] +
        self[4] * other[4]
    )
end

---Returns a new vector with the value of `a + b`.
---@param a Vec4
---@param b Vec4
---@return Vec4
function Vec4.__add(a, b)
    return a:clone():add(b)
end

---Returns a new vector with the value of `a - b`.
---@param a Vec4
---@param b Vec4
---@return Vec4
function Vec4.__sub(a, b)
    return a:clone():sub(b)
end

---Returns a new vector with the value of `a * b`.
---@param a Vec4
---@param b Vec4
---@return Vec4
function Vec4.__mul(a, b)
    return a:clone():mul(b)
end

---Returns a new vector with the value of `a / b`.
---@param a Vec4
---@param b Vec4
---@return Vec4
function Vec4.__div(a, b)
    return a:clone():div(b)
end

---Returns a new vector with the value of `-a`.
---@param a Vec4
---@return Vec4
function Vec4.__unm(a)
    return a:clone():neg()
end

function Vec4:__tostring()
    return 'Vec4(' .. self[1] .. ',' .. self[2] .. ',' .. self[3] .. ',' .. self[4] .. ')'
end

return Vec4