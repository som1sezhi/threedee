local class = require "threedee.class"
local Mat3 = require "threedee.math.Mat3"

local asin = math.asin
local atan2 = math.atan2
local min = math.min
local max = math.max
local abs = math.abs
local deg = math.deg
local matrix = Mat3:new()

local function clamp(x, lo, hi)
    return max(lo, min(hi, x))
end

---@alias EulerOrder 'xyz'|'xzy'|'yxz'|'yzx'|'zxy'|'zyx'

---A rotation represented as Euler angles.
---Note that positive angles go clockwise when viewing in the positive direction
---of the axis (e.g. looking rightwards for the X axis).
---@class Euler
---@field [1] number rotation around X axis (radians)
---@field [2] number rotation around Y axis (radians)
---@field [3] number rotation around Z axis (radians)
---@field order EulerOrder order in which to apply the rotations
local Euler = class('Euler')

Euler.DEFAULT_ORDER = 'zyx'

---Creates a new Euler object.
---Note that positive angles go clockwise when viewing in the positive direction
---of the axis (e.g. looking rightwards for the X axis).
---@param x? number rotation around X axis (radians)
---@param y? number rotation around Y axis (radians)
---@param z? number rotation around Z axis (radians)
---@param order? EulerOrder order in which to apply the rotations
---@return Euler
function Euler:new(x, y, z, order)
    order = order or Euler.DEFAULT_ORDER
    return setmetatable({ x or 0, y or 0, z or 0, order = order }, self)
end

---@return Euler
function Euler:clone()
    return Euler:new(self[1], self[2], self[3], self.order)
end

---@param source Euler
---@return self
function Euler:copy(source)
    self[1], self[2], self[3], self.order = source[1], source[2], source[3], source.order
    return self
end

---@param x number
---@param y number
---@param z number
---@return self
function Euler:set(x, y, z)
    self[1], self[2], self[3] = x, y, z
    return self
end

---@param m Mat3 a pure rotation matrix
---@param order? EulerOrder
---@return self
function Euler:setFromMat3(m, order)
    order = order or Euler.DEFAULT_ORDER
    local m11, m12, m13 = m[1], m[4], m[7]
    local m21, m22, m23 = m[2], m[5], m[8]
    local m31, m32, m33 = m[3], m[6], m[9]

    if order == 'zyx' then
        self[2] = asin(-clamp(m31, -1, 1));

        if abs(m31) < 0.9999999 then
            self[1] = atan2(m32, m33);
            self[3] = atan2(m21, m11);
        else
            self[1] = 0;
            self[3] = atan2(-m12, m22);
        end
    elseif order == 'xyz' then
        self[2] = asin(clamp(m13, -1, 1))
        if abs(m13) < 0.9999999 then
            self[1] = atan2(-m23, m33)
            self[3] = atan2(-m12, m11)
        else
            self[1] = atan2(m32, m22)
            self[3] = 0
        end
    elseif order == 'yxz' then
        self[1] = asin(-clamp(m23, -1, 1));

        if abs(m23) < 0.9999999 then
            self[2] = atan2(m13, m33);
            self[3] = atan2(m21, m22);
        else
            self[2] = atan2(-m31, m11);
            self[3] = 0;
        end
    elseif order == 'zxy' then
        self[1] = asin(clamp(m32, -1, 1));

        if abs(m32) < 0.9999999 then
            self[2] = atan2(-m31, m33);
            self[3] = atan2(-m12, m22);
        else
            self[2] = 0;
            self[3] = atan2(m21, m11);
        end
    elseif order == 'yzx' then
        self[3] = asin(clamp(m21, -1, 1));

        if abs(m21) < 0.9999999 then
            self[1] = atan2(-m23, m22);
            self[2] = atan2(-m31, m11);
        else
            self[1] = 0;
            self[2] = atan2(m13, m33);
        end
    elseif order == 'xzy' then
        self[3] = asin(-clamp(m12, -1, 1));

        if abs(m12) < 0.9999999 then
            self[1] = atan2(m32, m22);
            self[2] = atan2(m13, m11);
        else
            self[1] = atan2(-m23, m33);
            self[2] = 0;
        end
    end
    return self
end

---@param q Quat
---@param order? EulerOrder
---@return self
function Euler:setFromQuat(q, order)
    matrix:setFromQuat(q)
    return self:setFromMat3(matrix, order)
end

---Unpacks the Euler into 3 numbers that can be consumed by `Actor:rotationxyz()` and such.
---This converts the components into degrees, and also negates the Z component because 
---for some reason NotITG's Z rotation matrix rotates in the opposite direction of
---the other rotation matrices.
---@return number, number, number
function Euler:nitgUnpack()
    -- source for the above comment:
    -- https://www.geometrictools.com/Documentation/EulerAngles.pdf
    -- https://github.com/openitg/openitg/blob/f2c129fe65c65e4a9b3a691ff35e7717b4e8de51/src/RageMath.cpp#L222
    -- compare the Z rotation matrices (OpenITG matrices are row-major btw), you can see
    -- the sin(angle) components are swapped
    return deg(self[1]), deg(self[2]), -deg(self[3])
end

function Euler:__tostring()
    return 'Euler(' .. self[1] .. ',' .. self[2] .. ',' .. self[3] .. ',' .. self.order .. ')'
end

return Euler
