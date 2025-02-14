local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'
local Mat3 = require 'threedee.math.Mat3'

local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local WORLD_UP = Vec3:new(0, -1, 0)

---@class Quat
---@field [1] number
---@field [2] number
---@field [3] number
---@field [4] number (real part)
local Quat = class('Quat')

---@param x? number x component
---@param y? number y component
---@param z? number z component
---@param w? number w component (real part)
---@return Quat
function Quat:new(x, y, z, w)
    return setmetatable({x, y, z, w}, self)
end

---@return Quat
function Quat:identity()
    return self:new(0, 0, 0, 1)
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

---Sets quaternion from a rotation matrix
---@param rot Mat3 rotation matrix
---@return self
function Quat:setFromMatrix(rot)
    -- http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm
    local m00, m10, m20,
        m01, m11, m21,
        m02, m12, m22 = unpack(rot)
    local tr = m00 + m11 + m22

    if tr > 0 then
        local S = sqrt(tr + 1) * 2 -- S=4*qw 
        self[4] = 0.25 * S
        self[1] = (m21 - m12) / S
        self[2] = (m02 - m20) / S
        self[3] = (m10 - m01) / S
    elseif (m00 > m11) and (m00 > m22) then
        local S = sqrt(1 + m00 - m11 - m22) * 2 -- S=4*qx 
        self[4] = (m21 - m12) / S
        self[1] = 0.25 * S
        self[2] = (m01 + m10) / S
        self[3] = (m02 + m20) / S
    elseif m11 > m22 then
        local S = sqrt(1 + m11 - m00 - m22) * 2 -- S=4*qy
        self[4] = (m02 - m20) / S
        self[1] = (m01 + m10) / S
        self[2] = 0.25 * S
        self[3] = (m12 + m21) / S
    else
        local S = sqrt(1 + m22 - m00 - m11) * 2 -- S=4*qz
        self[4] = (m10 - m01) / S
        self[1] = (m02 + m20) / S
        self[2] = (m12 + m21) / S
        self[3] = 0.25 * S
    end
    return self
end

---@return self
function Quat:normalize()
	local n = self[1] * self[1] + self[2] * self[2] + self[3] * self[3] + self[4] * self[4]
	
	if n ~= 1 and n > 0 then
		n = 1 / sqrt(n)
		self[1] = self[1] * n
		self[2] = self[2] * n
		self[3] = self[3] * n
		self[4] = self[4] * n
	end
    return self
end

---@param forwards Vec3
---@param up? Vec3
---@return self
function Quat:lookRotation(forwards, up)
    up = up or WORLD_UP

    local zaxis = (-forwards):normalize()
    local xaxis = zaxis:cross(up):normalize()
    local yaxis = zaxis:cross(xaxis)

    local rot = Mat3:new(
        xaxis[1], yaxis[1], zaxis[1],
        xaxis[2], yaxis[2], zaxis[2],
        xaxis[3], yaxis[3], zaxis[3]
    )
    self:setFromMatrix(rot)
    return self
end

return Quat