local class = require 'threedee.class'

local cos = math.cos
local sin = math.sin

---@class Mat3
---@field [1] number
---@field [2] number
---@field [3] number
---@field [4] number
---@field [5] number
---@field [6] number
---@field [7] number
---@field [8] number
---@field [9] number
---@operator add(Mat3): Mat3
---@operator sub(Mat3): Mat3
---@operator mul(Mat3): Mat3
---@operator unm(Mat3): Mat3
local Mat3 = class('Mat3')

---Note: entries are in column-major order
---@param a11? number
---@param a21? number
---@param a31? number
---@param a12? number
---@param a22? number
---@param a32? number
---@param a13? number
---@param a23? number
---@param a33? number
---@return Mat3
function Mat3:new(
    a11, a21, a31,
    a12, a22, a32,
    a13, a23, a33
)
    local o = setmetatable({
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    }, self)
    if a11 ~= nil then
        return o:set(
            a11, a21, a31,
            a12, a22, a32,
            a13, a23, a33
        )
    end
    return o
end

---@return self
function Mat3:identity()
    return self:set(
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    )
end

---@return Mat3
function Mat3:clone()
    return Mat3:new(unpack(self))
end

---@param source Mat3
---@return self
function Mat3:copy(source)
    for i = 1, 9 do
        self[i] = source[i]
    end
    return self
end

---Note: entries are in column-major order
---@param a11 number
---@param a21 number
---@param a31 number
---@param a12 number
---@param a22 number
---@param a32 number
---@param a13 number
---@param a23 number
---@param a33 number
---@return Mat3
function Mat3:set(
    a11, a21, a31,
    a12, a22, a32,
    a13, a23, a33
)
    self[1], self[2], self[3] = a11, a21, a31
    self[4], self[5], self[6] = a12, a22, a32
    self[7], self[8], self[9] = a13, a23, a33
    return self
end

---@param mat Mat4
---@return self
function Mat3:setFromMat4(mat)
    self[1], self[4], self[7] = mat[1], mat[5], mat[9]
    self[2], self[5], self[8] = mat[2], mat[6], mat[10]
    self[3], self[6], self[9] = mat[3], mat[7], mat[11]
    return self
end

---@param q Quat
---@return self
function Mat3:setFromQuat(q)
    -- https://automaticaddison.com/how-to-convert-a-quaternion-to-a-rotation-matrix/
    local q0, q1, q2, q3 = q[4], q[1], q[2], q[3]
    self[1] = 2 * (q0 * q0 + q1 * q1) - 1
    self[4] = 2 * (q1 * q2 - q0 * q3)
    self[7] = 2 * (q1 * q3 + q0 * q2)
    self[2] = 2 * (q1 * q2 + q0 * q3)
    self[5] = 2 * (q0 * q0 + q2 * q2) - 1
    self[8] = 2 * (q2 * q3 - q0 * q1)
    self[3] = 2 * (q1 * q3 - q0 * q2)
    self[6] = 2 * (q2 * q3 + q0 * q1)
    self[9] = 2 * (q0 * q0 + q3 * q3) - 1
    return self
end

---@param euler Euler
---@return self
function Mat3:setFromEuler(euler)
    -- from three.js
    -- https://github.com/mrdoob/three.js/blob/c6620cee323838ead14035b37008f401edbc2ea1/src/math/Matrix4.js#L318
    local x, y, z, order = euler[1], euler[2], euler[3], euler.order
    local a, b, c, d, e, f = cos(x), sin(x), cos(y), sin(y), cos(z), sin(z)

    if order == 'zyx' then
        local ae, af, be, bf = a * e, a * f, b * e, b * f

        self[1] = c * e
        self[4] = be * d - af
        self[7] = ae * d + bf

        self[2] = c * f
        self[5] = bf * d + ae
        self[8] = af * d - be

        self[3] = - d
        self[6] = b * c
        self[9] = a * c
    elseif order == 'xyz' then
        local ae, af, be, bf = a * e, a * f, b * e, b * f

        self[1] = c * e
        self[4] = - c * f
        self[7] = d

        self[2] = af + be * d
        self[5] = ae - bf * d
        self[8] = - b * c

        self[3] = bf - ae * d
        self[6] = be + af * d
        self[9] = a * c
    elseif order == 'yxz' then
        local ce, cf, de, df = c * e, c * f, d * e, d * f

        self[1] = ce + df * b
        self[4] = de * b - cf
        self[7] = a * d

        self[2] = a * f
        self[5] = a * e
        self[8] = - b

        self[3] = cf * b - de
        self[6] = df + ce * b
        self[9] = a * c
    elseif order == 'zxy' then
        local ce, cf, de, df = c * e, c * f, d * e, d * f

        self[1] = ce - df * b
        self[4] = - a * f
        self[7] = de + cf * b

        self[2] = cf + de * b
        self[5] = a * e
        self[8] = df - ce * b

        self[3] = - a * d
        self[6] = b
        self[9] = a * c
    elseif order == 'yzx' then
        local ac, ad, bc, bd = a * c, a * d, b * c, b * d

        self[1] = c * e
        self[4] = bd - ac * f
        self[7] = bc * f + ad

        self[2] = f
        self[5] = a * e
        self[8] = - b * e

        self[3] = - d * e
        self[6] = ad * f + bc
        self[9] = ac - bd * f
    elseif order == 'xzy' then
        local ac, ad, bc, bd = a * c, a * d, b * c, b * d

        self[1] = c * e
        self[4] = - f
        self[7] = d * e

        self[2] = ac * f + bd
        self[5] = a * e
        self[8] = ad * f - bc

        self[3] = bc * f - ad
        self[6] = b * e
        self[9] = bd * f + ac
    end
    return self
end

---Sets `self` to the rotation matrix specified by `axis` and `angle`.
---Note that positive angles go clockwise when viewing in the positive direction
---of the axis (e.g. looking rightwards for the X axis).
---@param axis Vec3 axis of rotation (unit vector)
---@param angle number angle (radians)
---@return self
function Mat3:setFromAxisAngle(axis, angle)
    -- from three.js and https://www.gamedev.net/reference/articles/article1199.asp
    axis = axis:clone():normalize()
    local x, y, z = axis[1], axis[2], axis[3]
    local c, s = cos(angle), sin(angle)
    local t = 1 - c
    local tx, ty = t * x, t * y
    return self:set(
        tx*x + c, tx*y + s*z, tx*z - s*y,
        tx*y - s*z, ty*y + c, ty*z + s*x,
        tx*z + s*y, ty*z - s*x, t*z*z + c
    )
end

---@param row1 Vec3
---@param row2 Vec3
---@param row3 Vec3
function Mat3:setFromRows(row1, row2, row3)
    return self:set(
        row1[1], row2[1], row3[1],
        row1[2], row2[2], row3[2],
        row1[3], row2[3], row3[3]
    )
end

---@param col1 Vec3
---@param col2 Vec3
---@param col3 Vec3
function Mat3:setFromCols(col1, col2, col3)
    return self:set(
        col1[1], col1[2], col1[3],
        col2[1], col2[2], col2[3],
        col3[1], col3[2], col3[3]
    )
end

---@param other Mat3
---@return self
function Mat3:add(other)
    for i = 1, 9 do
        self[i] = self[i] + other[i]
    end
    return self
end

---@param other Mat3
---@return self
function Mat3:sub(other)
    for i = 1, 9 do
        self[i] = self[i] - other[i]
    end
    return self
end

---@return self
function Mat3:neg()
    for i = 1, 9 do
        self[i] = -self[i]
    end
    return self
end

---@param r number
---@return self
function Mat3:scale(r)
    for i = 1, 9 do
        self[i] = self[i] * r
    end
    return self
end

---@param other Mat3
---@return self
function Mat3:mul(other)
    return self:mulMatrices(self, other)
end

---@param other Mat3
---@return self
function Mat3:premul(other)
    return self:mulMatrices(other, self)
end

---@param matrixA Mat3
---@param matrixB Mat3
---@return self
function Mat3:mulMatrices(matrixA, matrixB)
    local a11, a21, a31,
        a12, a22, a32,
        a13, a23, a33 = unpack(matrixA)
    local b11, b21, b31,
        b12, b22, b32,
        b13, b23, b33 = unpack(matrixB)
    self[1] = a11*b11 + a12*b21 + a13*b31
    self[2] = a21*b11 + a22*b21 + a23*b31
    self[3] = a31*b11 + a32*b21 + a33*b31

    self[4] = a11*b12 + a12*b22 + a13*b32
    self[5] = a21*b12 + a22*b22 + a23*b32
    self[6] = a31*b12 + a32*b22 + a33*b32

    self[7] = a11*b13 + a12*b23 + a13*b33
    self[8] = a21*b13 + a22*b23 + a23*b33
    self[9] = a31*b13 + a32*b23 + a33*b33
    return self
end

---@return self
function Mat3:transpose()
    self[2], self[4] = self[4], self[2]
    self[3], self[7] = self[7], self[3]
    self[6], self[8] = self[8], self[6]
    return self
end

---@param a Mat3
---@param b Mat3
---@return Mat3
function Mat3.__add(a, b)
    return a:clone():add(b)
end

---@param a Mat3
---@param b Mat3
---@return Mat3
function Mat3.__sub(a, b)
    return a:clone():sub(b)
end

---@param a Mat3
---@param b Mat3
---@return Mat3
function Mat3.__mul(a, b)
    return a:clone():mul(b)
end

---@param a Mat3
---@return Mat3
function Mat3.__unm(a)
    return a:clone():neg()
end

function Mat3:__tostring()
    return string.format(
        'Mat3 [\n'..
        '  %f, %f, %f\n'..
        '  %f, %f, %f\n'..
        '  %f, %f, %f\n'..
        ']',
        self[1], self[4], self[7],
        self[2], self[5], self[8],
        self[3], self[6], self[9]
    )
end

return Mat3