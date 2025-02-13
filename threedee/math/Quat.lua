local class = require 'threedee.class'

local sin = math.sin
local cos = math.cos

---@class Quat
---@field [1] number
---@field [2] number
---@field [3] number
---@field [4] number (real part)
local Quat = class('Quat')

---Creates a new quaternion.
---Gives the identity quaternion if no arguments are passed in.
---@param x? number x component
---@param y? number y component
---@param z? number z component
---@param w? number w component (real part)
---@return Quat
function Quat:new(x, y, z, w)
    return setmetatable({x or 0, y or 0, z or 0, w or 1}, self)
end

---@return Quat
function Quat:clone()
    return Quat:new(self[1], self[2], self[3], self[4])
end

---@param axis Vec3 axis of rotation (unit vector)
---@param angle number angle (radians)
---@return self
function Quat:setFromAxisAngle(axis, angle)
    local s = sin(angle / 2)
    self[1] = axis[1] * s
    self[2] = axis[2] * s
    self[3] = axis[3] * s
    self[4] = cos(angle / 2)
    return self
end

---@param x number
---@param y number
---@param z number
---@param order? string euler axis order (default 'zyx')
---@return self
function Quat:setFromEuler(x, y, z, order)
    order = order or 'zyx'

    local c1, c2, c3 = cos(x / 2), cos(y / 2), cos(z / 2)
    local s1, s2, s3 = sin(x / 2), sin(y / 2), sin(z / 2)

    if order == 'zyx' then
        self[1] = s1 * c2 * c3 - c1 * s2 * s3
        self[2] = c1 * s2 * c3 + s1 * c2 * s3
        self[3] = c1 * c2 * s3 - s1 * s2 * c3
        self[4] = c1 * c2 * c3 + s1 * s2 * s3
    elseif order == 'xyz' then
        self[1] = s1 * c2 * c3 + c1 * s2 * s3
        self[2] = c1 * s2 * c3 - s1 * c2 * s3
        self[3] = c1 * c2 * s3 + s1 * s2 * c3
        self[4] = c1 * c2 * c3 - s1 * s2 * s3
    elseif order == 'yxz' then
        self[1] = s1 * c2 * c3 + c1 * s2 * s3
        self[2] = c1 * s2 * c3 - s1 * c2 * s3
        self[3] = c1 * c2 * s3 - s1 * s2 * c3
        self[4] = c1 * c2 * c3 + s1 * s2 * s3
    elseif order == 'zxy' then
        self[1] = s1 * c2 * c3 - c1 * s2 * s3
        self[2] = c1 * s2 * c3 + s1 * c2 * s3
        self[3] = c1 * c2 * s3 + s1 * s2 * c3
        self[4] = c1 * c2 * c3 - s1 * s2 * s3
    elseif order == 'yzx' then
        self[1] = s1 * c2 * c3 + c1 * s2 * s3
        self[2] = c1 * s2 * c3 + s1 * c2 * s3
        self[3] = c1 * c2 * s3 - s1 * s2 * c3
        self[4] = c1 * c2 * c3 - s1 * s2 * s3
    elseif order == 'xzy' then
        self[1] = s1 * c2 * c3 - c1 * s2 * s3
        self[2] = c1 * s2 * c3 - s1 * c2 * s3
        self[3] = c1 * c2 * s3 + s1 * s2 * c3
        self[4] = c1 * c2 * c3 + s1 * s2 * s3
    end
    return self
end