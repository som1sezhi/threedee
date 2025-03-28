local class = require 'threedee.class'
local Updatable = require 'threedee.Updatable'
local Vec3 = require 'threedee.math.Vec3'
local Quat = require 'threedee.math.Quat'
local Mat3 = require 'threedee.math.Mat3'
local Mat4 = require 'threedee.math.Mat4'

---Base class for a thing in 3D space with a position and orientation (cameras, lights)
---@class OrientedObject: Updatable
---@field position Vec3 (U) The position of this object. Default: `(0, 0, 0)`
---@field rotation Quat (U) The rotation of this object. Default: identity quaternion (no rotation)
---@field viewMatrix Mat4 (R) The object's view matrix. Automatically updated whenever `position` or `rotation` is updated via `:update()` or `:lookAt()`.
local OrientedObject = class('OrientedObject', Updatable)

---@class (partial) OrientedObject.P: OrientedObject

---@generic O: OrientedObject
---@param self O
---@param position? Vec3
---@param rotation? Quat
---@return O
function OrientedObject.new(self, position, rotation)
    local o = setmetatable({
        position = position and position:clone() or Vec3:new(0, 0, 0),
        rotation = rotation and rotation:clone() or Quat:new(),
        viewMatrix = Mat4:new(),
    }, self)
    o:updateViewMatrix()
    return o
end

---Updates the object's position and/or rotation. If you already calculated the
---viewMatrix elsewhere, you can pass that in too to avoid re-calculating it here.
---@type fun(self: OrientedObject, props: OrientedObject.P)
OrientedObject.update = Updatable.update

local tempMat3 = Mat3:new()

---@protected
---@param props OrientedObject.P
function OrientedObject:_update(props)
    Updatable._update(self, props)

    if not props.viewMatrix then
        -- update rotation part of view matrix
        if props.rotation then
            tempMat3:setFromQuat(self.rotation:clone():conj())
            self.viewMatrix:setUpperMat3(tempMat3)
        end
        -- update translation part of view matrix (based on rotation part)
        if props.position or props.rotation then
            local m = self.viewMatrix
            m[13] = -self.position:dot(Vec3:new(m[1], m[5], m[9]))
            m[14] = -self.position:dot(Vec3:new(m[2], m[6], m[10]))
            m[15] = -self.position:dot(Vec3:new(m[3], m[7], m[11]))
        end
    end
end

---Positions `self` at `eyePos`, and rotates it to look at `targetPos`, 
---with its viewpoint oriented with its up vector pointed in the
---direction hinted by `up`. If `up` is not given, a default of
---`(0, -1, 0)` (the world up-direction) 'will be used.'
---@param eyePos Vec3
---@param targetPos Vec3
---@param up? Vec3
function OrientedObject:lookAt(eyePos, targetPos, up)
    self:update({
        position = eyePos,
        rotation = self.rotation:lookRotation(targetPos - eyePos, up)
    })
end

---Force-update the view matrix.
function OrientedObject:updateViewMatrix()
    local m = self.viewMatrix
    tempMat3:setFromQuat(self.rotation:clone():conj())
    m:setUpperMat3(tempMat3)
    m[13] = -self.position:dot(Vec3:new(m[1], m[5], m[9]))
    m[14] = -self.position:dot(Vec3:new(m[2], m[6], m[10]))
    m[15] = -self.position:dot(Vec3:new(m[3], m[7], m[11]))
end

return OrientedObject