local class = require "threedee.class"
---@class Mat4
---@field [1] number
---@field [2] number
---@field [3] number
---@field [4] number
---@field [5] number
---@field [6] number
---@field [7] number
---@field [8] number
---@field [9] number
---@field [10] number
---@field [11] number
---@field [12] number
---@field [13] number
---@field [14] number
---@field [15] number
---@field [16] number
---@operator add(Mat4): Mat4
---@operator sub(Mat4): Mat4
---@operator mul(Mat4): Mat4
---@operator unm(Mat4): Mat4
local Mat4 = class('Mat4')

---Note: entries are in column-major order
---@param a11 number
---@param a21 number
---@param a31 number
---@param a41 number
---@param a12 number
---@param a22 number
---@param a32 number
---@param a42 number
---@param a13 number
---@param a23 number
---@param a33 number
---@param a43 number
---@param a14 number
---@param a24 number
---@param a34 number
---@param a44 number
---@return Mat4
function Mat4:new(
    a11, a21, a31, a41,
    a12, a22, a32, a42,
    a13, a23, a33, a43,
    a14, a24, a34, a44
)
    return setmetatable({
        a11, a21, a31, a41,
        a12, a22, a32, a42,
        a13, a23, a33, a43,
        a14, a24, a34, a44
    }, self)
end

---@return Mat4
function Mat4:identity()
    return Mat4:new(
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    )
end

---@return Mat4
function Mat4:clone()
    return Mat4:new(unpack(self))
end

---@param mat Mat3
---@return self
function Mat4:setMat3(mat)
    self[1], self[5], self[9] = mat[1], mat[4], mat[7]
    self[2], self[6], self[10] = mat[2], mat[5], mat[8]
    self[3], self[7], self[11] = mat[3], mat[6], mat[9]
    return self
end

---@param other Mat4
---@return self
function Mat4:add(other)
    for i = 1, 16 do
        self[i] = self[i] + other[i]
    end
    return self
end

---@param other Mat4
---@return self
function Mat4:sub(other)
    for i = 1, 16 do
        self[i] = self[i] - other[i]
    end
    return self
end

---@param other Mat4
---@return self
function Mat4:mul(other)
    for i = 1, 16 do
        self[i] = self[i] * other[i]
    end
    return self
end

---@param other Mat4
---@return self
function Mat4:div(other)
    for i = 1, 16 do
        self[i] = self[i] / other[i]
    end
    return self
end

---@return self
function Mat4:neg()
    for i = 1, 16 do
        self[i] = -self[i]
    end
    return self
end

---@param r number
---@return self
function Mat4:scale(r)
    for i = 1, 16 do
        self[i] = self[i] * r
    end
    return self
end

---@param other Mat4
---@return self
function Mat4:matmul(other)
    local a11, a21, a31, a41,
        a12, a22, a32, a42,
        a13, a23, a33, a43,
        a14, a24, a34, a44 = unpack(self)
    local b11, b21, b31, b41,
        b12, b22, b32, b42,
        b13, b23, b33, b43,
        b14, b24, b34, b44 = unpack(other)
    self[1] = a11*b11 + a12*b21 + a13*b31 + a14*b41
    self[2] = a21*b11 + a22*b21 + a23*b31 + a24*b41
    self[3] = a31*b11 + a32*b21 + a33*b31 + a34*b41
    self[4] = a41*b11 + a42*b21 + a43*b31 + a44*b41

    self[5] = a11*b12 + a12*b22 + a13*b32 + a14*b42
    self[6] = a21*b12 + a22*b22 + a23*b32 + a24*b42
    self[7] = a31*b12 + a32*b22 + a33*b32 + a34*b42
    self[8] = a41*b12 + a42*b22 + a43*b32 + a44*b42

    self[9]  = a11*b13 + a12*b23 + a13*b33 + a14*b43
    self[10] = a21*b13 + a22*b23 + a23*b33 + a24*b43
    self[11] = a31*b13 + a32*b23 + a33*b33 + a34*b43
    self[12] = a41*b13 + a42*b23 + a43*b33 + a44*b43

    self[13] = a11*b14 + a12*b24 + a13*b34 + a14*b44
    self[14] = a21*b14 + a22*b24 + a23*b34 + a24*b44
    self[15] = a31*b14 + a32*b24 + a33*b34 + a34*b44
    self[16] = a41*b14 + a42*b24 + a43*b34 + a44*b44
    return self
end

---@param a Mat4
---@param b Mat4
---@return Mat4
function Mat4.__add(a, b)
    return a:clone():add(b)
end

---@param a Mat4
---@param b Mat4
---@return Mat4
function Mat4.__sub(a, b)
    return a:clone():sub(b)
end

---@param a Mat4
---@param b Mat4
---@return Mat4
function Mat4.__mul(a, b)
    return a:clone():matmul(b)
end

---@param a Mat4
---@return Mat4
function Mat4.__unm(a)
    return a:clone():neg()
end

return Mat4