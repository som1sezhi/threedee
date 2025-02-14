local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'
local Quat = require 'threedee.math.Quat'
local Mat3 = require 'threedee.math.Mat3'
local Mat4 = require 'threedee.math.Mat4'

---Base class for a thing in 3D space with a position and orientation (cameras, lights)
---@class OrientedObject
---@field position Vec3
---@field rotation Quat
---@field viewMatrix Mat4
---@field _viewMatTranslationNeedsUpdate boolean
---@field _viewMatRotationNeedsUpdate boolean
local OrientedObject = class('Object3D')

---@generic O: OrientedObject
---@param self O
---@param position? Vec3
---@param rotation? Quat
---@return O
function OrientedObject.new(self, position, rotation)
    local o = setmetatable({
        position = position or Vec3:new(0, 0, 0),
        rotation = rotation or Quat:identity(),
        viewMatrix = Mat4:identity(),
        _positionChanged = true,
        _rotationChanged = true,
    }, self)
    o:updateViewMatrix()
    return o
end

---@param newPos Vec3
function OrientedObject:setPosition(newPos)
    self.position = newPos
    self._viewMatTranslationNeedsUpdate = true
end

---@param newRot Quat
function OrientedObject:setRotation(newRot)
    self.rotation = newRot
    self._viewMatRotationNeedsUpdate = true
end

---@param targetPos Vec3
---@param up? Vec3
function OrientedObject:lookAt(targetPos, up)
    self.rotation = self.rotation:lookRotation(targetPos - self.position, up)
    self._viewMatRotationNeedsUpdate = true
end

function OrientedObject:updateViewMatrix()
    if self._viewMatRotationNeedsUpdate then
        local rot = Mat3:identity():setFromQuat(self.rotation)
        self.viewMatrix:setMat3(rot)
        self._viewMatTranslationNeedsUpdate = true -- update translation part of matrix based on new rotation part
        self._viewMatRotationNeedsUpdate = false
    end
    if self._viewMatTranslationNeedsUpdate then
        local m = self.viewMatrix
        self.viewMatrix[13] = -self.position:dot(Vec3:new(m[1], m[5], m[9]))
        self.viewMatrix[14] = -self.position:dot(Vec3:new(m[2], m[6], m[10]))
        self.viewMatrix[15] = -self.position:dot(Vec3:new(m[3], m[7], m[11]))
        self._viewMatTranslationNeedsUpdate = false
    end
end

function OrientedObject:getViewMatrix()
    self:updateViewMatrix()
    return self.viewMatrix
end

return OrientedObject