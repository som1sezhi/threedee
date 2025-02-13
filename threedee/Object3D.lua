local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'
local Quat = require 'threedee.math.Quat'

---Base class for a thing in 3D space with a position and rotation (no scaling yet)
---@class Object3D
---@field position Vec3
---@field rotation Quat
local Object3D = class('Object3D')