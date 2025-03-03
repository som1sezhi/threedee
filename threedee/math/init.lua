local Vec3 = require 'threedee.math.Vec3'
local Vec4 = require 'threedee.math.Vec4'
local Mat3 = require 'threedee.math.Mat3'
local Mat4 = require 'threedee.math.Mat4'
local Quat = require 'threedee.math.Quat'
local Euler = require 'threedee.math.Euler'
local color = require 'threedee.math.color'

local m = {
    Vec3 = Vec3,
    Vec4 = Vec4,
    Mat3 = Mat3,
    Mat4 = Mat4,
    Quat = Quat,
    Euler = Euler,
    color = color
}

return m