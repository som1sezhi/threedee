local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'
local Mat3 = require 'threedee.math.Mat3'

local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local abs = math.abs
local acos = math.acos
local WORLD_UP = Vec3:new(0, -1, 0)
local matrix = Mat3:new()

---A quaternion, often used to represent rotations.
---@class Quat
---@field [1] number X component (imaginary).
---@field [2] number Y component (imaginary).
---@field [3] number Z component (imaginary).
---@field [4] number W component (real part).
local Quat = class('Quat')

---Creates a new quaternion.
---If no arguments are given, an identity quaternion is created.
---@param x? number
---@param y? number
---@param z? number
---@param w? number
---@return Quat
function Quat:new(x, y, z, w)
    return setmetatable({x or 0, y or 0, z or 0, w or 1}, self)
end

---Sets `self` to the identity quaternion (representing no rotation).
---@return self
function Quat:identity()
    return self:set(0, 0, 0, 1)
end

---Returns a copy of `self`.
---@return Quat
function Quat:clone()
    return Quat:new(self[1], self[2], self[3], self[4])
end

---Copies the components of `source` into `self`.
---@param source Quat
---@return self
function Quat:copy(source)
    self[1], self[2], self[3], self[4] = source[1], source[2], source[3], source[4]
    return self
end

---Sets the components of `self`.
---@param x number
---@param y number
---@param z number
---@param w number
---@return self
function Quat:set(x, y, z, w)
    self[1], self[2], self[3], self[4] = x, y, z, w
    return self
end

---Sets `self` to the rotation specified by `axis` and `angle`.
---`axis` must be a unit vector and `angle` should be specified in radians.
---Note that positive angles go clockwise when viewing in the positive direction
---of the axis (e.g. looking rightwards for the X axis).
---@param axis Vec3
---@param angle number
---@return self
function Quat:setFromAxisAngle(axis, angle)
    axis = axis:clone():normalize()
    local s = sin(angle / 2)
    self[1] = axis[1] * s
    self[2] = axis[2] * s
    self[3] = axis[3] * s
    self[4] = cos(angle / 2)
    return self
end

---Sets `self` to a rotation matrix as specified by Euler angles `euler`.
---@param euler Euler
---@return self
function Quat:setFromEuler(euler)
    local x, y, z, order = euler[1], euler[2], euler[3], euler.order

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

---Sets `self` to a rotation as specified by the rotation matrix `rot`.
---@param rot Mat3
---@return self
function Quat:setFromMat3(rot)
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

---Sets `self` to its conjugate (i.e. the opposite rotation to `self`).
---@return self
function Quat:conj()
    self[1] = -self[1]
    self[2] = -self[2]
    self[3] = -self[3]
    return self
end

---Multiplies `self` by `other`.
---@param other Quat
---@return self
function Quat:mul(other)
    return self:mulQuats(self, other)
end

---Pre-multiplies `self` by `other`.
---@param other Quat
---@return self
function Quat:premul(other)
    return self:mulQuats(other, self)
end

---Sets `self` to the result of multiplying `q1` by `q2`.
---@param q1 Quat
---@param q2 Quat
---@return self
function Quat:mulQuats(q1, q2)
    -- http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/code/index.htm
    local q1x, q1y, q1z, q1w = q1[1], q1[2], q1[3], q1[4]
    local q2x, q2y, q2z, q2w = q2[1], q2[2], q2[3], q2[4]
    self[1] = q1x * q2w + q1w * q2x + q1y * q2z - q1z * q2y
    self[2] = q1y * q2w + q1w * q2y + q1z * q2x - q1x * q2z
    self[3] = q1z * q2w + q1w * q2z + q1x * q2y - q1y * q2x
    self[4] = q1w * q2w - q1x * q2x - q1y * q2y - q1z * q2z
    return self
end

---Normalizes `self`.
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

---Sets `self` to a rotation that rotates `(0, 0, -1)` (the "forwards" direction)
---to the direction specified by `forwards`, with the up view direction oriented
---based on `up`. If `up` is not give, the world up direction `(0, -1, 0)` is
---used by default.
---@param forwards Vec3
---@param up? Vec3
---@return self
function Quat:lookRotation(forwards, up)
    up = up or WORLD_UP

    local zaxis = (-forwards):normalize()
    local xaxis = zaxis:clone():cross(up):normalize()
    local yaxis = zaxis:clone():cross(xaxis)

    matrix:set(
        xaxis[1], xaxis[2], xaxis[3],
        yaxis[1], yaxis[2], yaxis[3],
        zaxis[1], zaxis[2], zaxis[3]
    )
    self:setFromMat3(matrix)
    return self
end

---Sets self to the result of spherical linear interpolation from `self` to `qb`
---based on parameter `t`.
---@param qb Quat
---@param t number
---@return self
function Quat:slerp(qb, t)
    local x, y, z, w = self[1], self[2], self[3], self[4]
    -- https://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/slerp/
	local cosHalfTheta = x*qb[1] + y*qb[2] + z*qb[3] + w*qb[4]
	-- if self=qb or self=-qb then theta = 0 and we can return self
	if abs(cosHalfTheta) >= 1 then
		return self
    end
	-- Calculate temporary values.
	local halfTheta = acos(cosHalfTheta)
	local sinHalfTheta = sqrt(1 - cosHalfTheta*cosHalfTheta)
	-- if theta = 180 degrees then result is not fully defined
	-- we could rotate around any axis normal to qa or qb
	if abs(sinHalfTheta) < 0.001 then
		self[1] = (x * 0.5 + qb[1] * 0.5)
		self[2] = (y * 0.5 + qb[2] * 0.5)
		self[3] = (z * 0.5 + qb[3] * 0.5)
        self[4] = (w * 0.5 + qb[4] * 0.5)
		return self
    end
    -- calculate quaternion
	local ratioA = sin((1 - t) * halfTheta) / sinHalfTheta
	local ratioB = sin(t * halfTheta) / sinHalfTheta
	self[1] = (x * ratioA + qb[1] * ratioB);
	self[2] = (y * ratioA + qb[2] * ratioB);
	self[3] = (z * ratioA + qb[3] * ratioB);
	self[4] = (w * ratioA + qb[4] * ratioB);
	return self
end

---Returns the result of multiplying `a` and `b`.
function Quat.__mul(a, b)
    return a:clone():mul(b)
end

function Quat:__tostring()
    return string.format('Quat(%f,%f,%f,%f)', self[1], self[2], self[3], self[4])
end

return Quat