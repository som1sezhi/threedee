local Vec3 = require 'threedee.math.Vec3'
local Vec4 = require 'threedee.math.Vec4'
local Mat4 = require 'threedee.math.Mat4'
local color = require 'threedee.math.color'

local m = {
    Vec3 = Vec3,
    Vec4 = Vec4,
    Mat4 = Vec4,
    color = color
}

---Create a view matrix for a camera at position 'eye' looking at 'at'
---@param eye Vec3 camera position
---@param at Vec3 target position
---@param up Vec3 up vector (remember -Y is up in NotITG)
---@return Mat4
function m.lookAt(eye, at, up)
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
    local xaxis = zaxis:cross(up):normalize()
    -- our desired +Y vector points down in NotITG space, but will behave more
    -- like an up vector in the cross product's right-handed coord space.
    -- (+Z) x (+X) = (backwards) x (right) = (up) = (+Y) as wanted
    local yaxis = zaxis:cross(xaxis)

    return Mat4:new(
        xaxis[1], yaxis[1], zaxis[1], 0,
        xaxis[2], yaxis[2], zaxis[2], 0,
        xaxis[3], yaxis[3], zaxis[3], 0,
        -xaxis:dot(eye), -yaxis:dot(eye), -zaxis:dot(eye), 1
    )
end

---Create a projection matrix for a general frustum.
---All coordinates should be in view space.
---@param l number left coordinate
---@param r number right coordinate
---@param b number bottom coordinate
---@param t number top coordinate
---@param zn number near plane distance
---@param zf number far plane distance
---@return Mat4
function m.frustum(l, r, b, t, zn, zf)
    local A = (r+l) / (r-l)
    local B = (t+b) / (t-b)
    local C = -(zf+zn) / (zf-zn)
    local D = -(2*zf*zn) / (zf-zn)
    return Mat4:new(
        2*zn/(r-l), 0,          0,  0,
        0,          2*zn/(t-b), 0,  0,
        A,          B,          C,  -1,
        0,          0,          D,  0
    )
end

---Create a projection matrix for a symmetric frustum.
---Equivalent to `frustum(-r, r, -t, t, zn, zf)`.
---All coordinates should be in view space.
---@param r number right coordinate
---@param t number top coordinate
---@param zn number near plane distance
---@param zf number far plane distance
---@return Mat4
function m.symmetricFrustum(r, t, zn, zf)
    return Mat4:new(
        zn/r, 0, 0,  0,
        0, zn/t, 0,  0,
        0, 0, -(zf+zn)/(zf-zn), -1,
        0, 0, -2*zf*zn/(zf-zn), 0
    )
end

---Create a projection matrix for a perspective camera.
---@param fovY number vertical FOV (radians)
---@param aspectRatio number
---@param near number
---@param far number
function m.perspective(fovY, aspectRatio, near, far)
    local tangent = math.tan(fovY / 2)
    local bottom = near * tangent
    local right = bottom * aspectRatio
    -- top is negative here to flip the Y-axis from Y-down (NotITG convention)
    -- to Y-up (OpenGL convention)
    return m.symmetricFrustum(right, -bottom, near, far)
end

return m