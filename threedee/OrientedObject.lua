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
local OrientedObject = class('OrientedObject')

---@class (partial) OrientedObject.P: OrientedObject

---@generic O: OrientedObject
---@param self O
---@param position? Vec3
---@param rotation? Quat
---@return O
function OrientedObject.new(self, position, rotation)
    local o = setmetatable({
        position = position or Vec3:new(0, 0, 0),
        rotation = rotation or Quat:new(),
        viewMatrix = Mat4:new(),
    }, self)
    -- calculate viewMatrix via update method
    o:update({
        position = o.position,
        rotation = o.rotation
    })
    return o
end

local tempMat3 = Mat3:new()

---Updates the object's position and/or rotation. If you already calculated the
---viewMatrix elsewhere, you can pass that in too to avoid re-calculating it here.
---@param props OrientedObject.P
function OrientedObject:update(props)
    self:_update(props)
    self:onUpdate(props)
end

---@protected
---@param props OrientedObject.P
function OrientedObject:_update(props)
    local viewMatRotationNeedsUpdate = self.rotation
    local viewMatTranslationNeedsUpdate = self.position or self.rotation

    for k, v in pairs(props) do
        self[k] = v
    end

    if not props.viewMatrix then
        -- update rotation part of view matrix
        if viewMatRotationNeedsUpdate then
            tempMat3:setFromQuat(self.rotation)
            self.viewMatrix:setUpperMat3(tempMat3)
        end
        -- update translation part of view matrix (based on rotation part)
        if viewMatTranslationNeedsUpdate then
            local m = self.viewMatrix
            m[13] = -self.position:dot(Vec3:new(m[1], m[5], m[9]))
            m[14] = -self.position:dot(Vec3:new(m[2], m[6], m[10]))
            m[15] = -self.position:dot(Vec3:new(m[3], m[7], m[11]))
        end
    end
end

---@param eyePos Vec3
---@param targetPos Vec3
---@param up? Vec3
function OrientedObject:lookAt(eyePos, targetPos, up)
    self:update({
        position = eyePos,
        rotation = self.rotation:lookRotation(targetPos - eyePos, up)
    })
end

---Override this if you want to run some additional code whenever :update() is called,
---e.g. for dispatching events to materials that need the updated values.
---@param props OrientedObject.P
function OrientedObject:onUpdate(props)
end

return OrientedObject