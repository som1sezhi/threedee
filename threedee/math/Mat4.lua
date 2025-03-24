local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'

local WORLD_UP = Vec3:new(0, -1, 0)

---A 4x4 matrix. Entries are in column-major order.
---@class Mat4
---@field [1] number Element at row 1, column 1.
---@field [2] number Element at row 2, column 1.
---@field [3] number Element at row 3, column 1.
---@field [4] number Element at row 4, column 1.
---@field [5] number Element at row 1, column 2.
---@field [6] number Element at row 2, column 2.
---@field [7] number Element at row 3, column 2.
---@field [8] number Element at row 4, column 2.
---@field [9] number Element at row 1, column 3.
---@field [10] number Element at row 2, column 3.
---@field [11] number Element at row 3, column 3.
---@field [12] number Element at row 4, column 3.
---@field [13] number Element at row 1, column 4.
---@field [14] number Element at row 2, column 4.
---@field [15] number Element at row 3, column 4.
---@field [16] number Element at row 4, column 4.
---@operator add(Mat4): Mat4
---@operator sub(Mat4): Mat4
---@operator mul(Mat4): Mat4
---@operator unm(Mat4): Mat4
local Mat4 = class('Mat4')

---Creates a new Mat3.
---Entries should be specified in column-major order.
---If no arguments are given, the identity matrix is returned.
---@param a11? number
---@param a21? number
---@param a31? number
---@param a41? number
---@param a12? number
---@param a22? number
---@param a32? number
---@param a42? number
---@param a13? number
---@param a23? number
---@param a33? number
---@param a43? number
---@param a14? number
---@param a24? number
---@param a34? number
---@param a44? number
---@return Mat4
function Mat4:new(
    a11, a21, a31, a41,
    a12, a22, a32, a42,
    a13, a23, a33, a43,
    a14, a24, a34, a44
)
    local m = setmetatable({
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    }, self)
    if a11 ~= nil then
        return m:set(
            a11, a21, a31, a41,
            a12, a22, a32, a42,
            a13, a23, a33, a43,
            a14, a24, a34, a44
        )
    end
    return m
end

---Sets `self` to the identity matrix.
---@return self
function Mat4:identity()
    return self:set(
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    )
end

---Returns a copy of `self`.
---@return Mat4
function Mat4:clone()
    return Mat4:new(unpack(self))
end

---Copies the elements of `source` to `self`.
---@param source Mat4
---@return self
function Mat4:copy(source)
    for i = 1, 9 do
        self[i] = source[i]
    end
    return self
end

---Sets the entries of `self`.
---Entries should be specified in column-major order.
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
---@return self
function Mat4:set(
    a11, a21, a31, a41,
    a12, a22, a32, a42,
    a13, a23, a33, a43,
    a14, a24, a34, a44
)
    self[1], self[2], self[3], self[4] = a11, a21, a31, a41
    self[5], self[6], self[7], self[8] = a12, a22, a32, a42
    self[9], self[10], self[11], self[12] = a13, a23, a33, a43
    self[13], self[14], self[15], self[16] = a14, a24, a34, a44
    return self
end

---Sets the upper 3x3 submatrix of `self` to `mat`.
---@param mat Mat3
---@return self
function Mat4:setUpperMat3(mat)
    self[1], self[5], self[9] = mat[1], mat[4], mat[7]
    self[2], self[6], self[10] = mat[2], mat[5], mat[8]
    self[3], self[7], self[11] = mat[3], mat[6], mat[9]
    return self
end

---Sets `self` in terms of row vectors.
---@param row1 Vec4
---@param row2 Vec4
---@param row3 Vec4
---@param row4 Vec4
function Mat4:setFromRows(row1, row2, row3, row4)
    return self:set(
        row1[1], row2[1], row3[1], row4[1],
        row1[2], row2[2], row3[2], row4[2],
        row1[3], row2[3], row3[3], row4[3],
        row1[4], row2[4], row3[4], row4[4]
    )
end

---Sets `self` in terms of column vectors.
---@param col1 Vec4
---@param col2 Vec4
---@param col3 Vec4
---@param col4 Vec4
function Mat4:setFromCols(col1, col2, col3, col4)
    return self:set(
        col1[1], col1[2], col1[3], col1[4],
        col2[1], col2[2], col2[3], col2[4],
        col3[1], col3[2], col3[3], col3[4],
        col4[1], col4[2], col4[3], col4[4]
    )
end

---Sets `self` to the result of `self + other`.
---@param other Mat4
---@return self
function Mat4:add(other)
    for i = 1, 16 do
        self[i] = self[i] + other[i]
    end
    return self
end

---Sets `self` to the result of `self - other`.
---@param other Mat4
---@return self
function Mat4:sub(other)
    for i = 1, 16 do
        self[i] = self[i] - other[i]
    end
    return self
end

---Sets `self` to the result of `-self`.
---@return self
function Mat4:neg()
    for i = 1, 16 do
        self[i] = -self[i]
    end
    return self
end

---Scales `self` by the scalar `r`.
---@param r number
---@return self
function Mat4:scale(r)
    for i = 1, 16 do
        self[i] = self[i] * r
    end
    return self
end

---Sets `self` to the result of the matrix multiplication `self * other`.
---@param other Mat4
---@return self
function Mat4:mul(other)
    return self:mulMatrices(self, other)
end

---Sets `self` to the result of the matrix multiplication `other * self`.
---@param other Mat4
---@return self
function Mat4:premul(other)
    return self:mulMatrices(other, self)
end

---Sets `self` to the result of the matrix multiplication `matrixA * matrixB`.
---@param matrixA Mat4
---@param matrixB Mat4
---@return self
function Mat4:mulMatrices(matrixA, matrixB)
    local a11, a21, a31, a41,
        a12, a22, a32, a42,
        a13, a23, a33, a43,
        a14, a24, a34, a44 = unpack(matrixA)
    local b11, b21, b31, b41,
        b12, b22, b32, b42,
        b13, b23, b33, b43,
        b14, b24, b34, b44 = unpack(matrixB)
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

---Sets `self` to its `transpose`.
---@return self
function Mat4:transpose()
    -- 1 5 9  13
    -- 2 6 10 14
    -- 3 7 11 15
    -- 4 8 12 16
    self[2], self[5] = self[5], self[2]
    self[3], self[9] = self[9], self[3]
    self[4], self[13] = self[13], self[4]
    self[7], self[10] = self[10], self[7]
    self[8], self[14] = self[14], self[8]
    self[12], self[15] = self[15], self[12]
    return self
end

---Sets `self` to a view matrix for a camera at position `eye` looking at `at`, with the view's
---up direction oriented based on `up`. If `up` is not given, the world up vector `(0, -1, 0)` is used
---by default.
---
---Be aware that this gives a view matrix, not a world matrix for the camera/any other object.
---@param eye Vec3
---@param at Vec3
---@param up? Vec3
---@return self
function Mat4:lookAt(eye, at, up)
    up = up or WORLD_UP
    -- we want the vectors in world space that the view space unit vectors 
    -- (+X, +Y, +Z) correspond to.
    -- from camera POV, +X points right, +Y points down, +Z points backwards
    -- however, when dealing with the right-handed cross product,
    -- we may treat +Y like a vector that points up instead.

    -- vector pointing from target to camera (+Z in our view space)
    local zaxis = (eye - at):normalize()
    -- since up is -Y in NotITG's coord space, our up vector will behave more
    -- like a down vector in the cross product's right-handed coord space.
    -- (+Z) x (-Y) = (backwards) x (down) = (right) = (+X) as wanted
    local xaxis = zaxis:clone():cross(up):normalize()
    -- our desired +Y vector points down in NotITG space, but will behave more
    -- like an up vector in the cross product's right-handed coord space.
    -- (+Z) x (+X) = (backwards) x (right) = (up) = (+Y) as wanted
    local yaxis = zaxis:clone():cross(xaxis)

    return self:set(
        xaxis[1], yaxis[1], zaxis[1], 0,
        xaxis[2], yaxis[2], zaxis[2], 0,
        xaxis[3], yaxis[3], zaxis[3], 0,
        -xaxis:dot(eye), -yaxis:dot(eye), -zaxis:dot(eye), 1
    )
end

---Sets `self` to a projection matrix for a general frustum.
---All coordinates should be in view space.
---@param l number
---@param r number
---@param b number
---@param t number
---@param zn number
---@param zf number
---@return self
function Mat4:frustum(l, r, b, t, zn, zf)
    local A = (r+l) / (r-l)
    local B = (t+b) / (t-b)
    local C = -(zf+zn) / (zf-zn)
    local D = -(2*zf*zn) / (zf-zn)
    return self:set(
        2*zn/(r-l), 0, 0, 0,
        0, 2*zn/(t-b), 0, 0,
        A, B, C, -1,
        0, 0, D, 0
    )
end

---Sets `self` to a projection matrix for a symmetric frustum.
---Equivalent to `frustum(-r, r, -t, t, zn, zf)`.
---All coordinates should be in view space.
---@param r number
---@param t number
---@param zn number
---@param zf number
---@return self
function Mat4:symmetricFrustum(r, t, zn, zf)
    return self:set(
        zn/r, 0, 0,  0,
        0, zn/t, 0,  0,
        0, 0, -(zf+zn)/(zf-zn), -1,
        0, 0, -2*zf*zn/(zf-zn), 0
    )
end

---Sets `self` to a projection matrix for a perspective camera. Note that
---`fovY` specifies the vertical FOV in radians.
---@param fovY number
---@param aspectRatio number
---@param near number
---@param far number
---@return self
function Mat4:perspective(fovY, aspectRatio, near, far)
    local tangent = math.tan(fovY / 2)
    local bottom = near * tangent
    local right = bottom * aspectRatio
    -- top is negative here to flip the Y-axis from Y-down (NotITG convention)
    -- to Y-up (OpenGL convention)
    return self:symmetricFrustum(right, -bottom, near, far)
end

---Sets `self` to a projection matrix for an orthographic camera.
---@param l number
---@param r number
---@param t number
---@param b number
---@param near number
---@param far number
---@return Mat4
function Mat4:orthographic(l, r, t, b, near, far)
    return self:set(
        2/(r-l), 0, 0, 0,
        0, 2/(t-b), 0, 0,
        0, 0, -2/(far-near), 0,
        -(r+l)/(r-l), -(t+b)/(t-b), -(far+near)/(far-near), 1
    )
end

---Returns a new matrix with the value of `a + b`.
---@param a Mat4
---@param b Mat4
---@return Mat4
function Mat4.__add(a, b)
    return a:clone():add(b)
end

---Returns a new matrix with the value of `a - b`.
---@param a Mat4
---@param b Mat4
---@return Mat4
function Mat4.__sub(a, b)
    return a:clone():sub(b)
end

---Returns a new matrix with the value of `a * b`.
---@param a Mat4
---@param b Mat4
---@return Mat4
function Mat4.__mul(a, b)
    return a:clone():mul(b)
end

---Returns a new matrix with the value of `-a`.
---@param a Mat4
---@return Mat4
function Mat4.__unm(a)
    return a:clone():neg()
end

function Mat4:__tostring()
    return string.format(
        'Mat4 [\n'..
        '  %f, %f, %f, %f\n'..
        '  %f, %f, %f, %f\n'..
        '  %f, %f, %f, %f\n'..
        '  %f, %f, %f, %f\n'..
        ']',
        self[1], self[5], self[9], self[13],
        self[2], self[6], self[10], self[14],
        self[3], self[7], self[11], self[15],
        self[4], self[8], self[12], self[16]
    )
end

return Mat4