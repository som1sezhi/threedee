local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'
local cameras = require 'threedee.cameras'
local OrientedObject = require 'threedee.OrientedObject'

---@class LightShadow
---@field camera Camera

---Base class for all lights
---@class Light: OrientedObject
---@field color Vec3
---@field intensity number
---@field shadow? LightShadow
local Light = class('Light', OrientedObject)

---@generic L: Light
---@param self L
---@param color? Vec3
---@param intensity? number
---@param position? Vec3
---@param rotation? Quat
---@return L
function Light.new(self, color, intensity, position, rotation)
    local light = OrientedObject.new(self, position, rotation)
    light.color = color or Vec3:new(1, 1, 1)
    light.intensity = intensity or 1
    return light
end

function Light:setPosition(newPos)
    OrientedObject.setPosition(self, newPos)
    -- propagate transform changes to the shadow camera
    if self.shadow then
        self.shadow.camera:setPosition(newPos)
    end
end

function Light:setRotation(newRot)
    OrientedObject.setRotation(self, newRot)
    -- propagate transform changes to the shadow camera
    if self.shadow then
        self.shadow.camera:setRotation(newRot)
    end
end

function Light:lookAt(targetPos)
    OrientedObject.lookAt(self, targetPos)
    -- propagate transform changes to the shadow camera
    if self.shadow then
        self.shadow.camera:setRotation(self.rotation)
    end
end

function Light:updateViewMatrix()
    OrientedObject.updateViewMatrix(self)
    -- propagate transform changes to the shadow camera
    if self.shadow then
        -- no need to recalc the matrix if we already have it
        self.shadow.camera.viewMatrix = self.viewMatrix
        self.shadow.camera._viewMatTranslationNeedsUpdate = false
        self.shadow.camera._viewMatRotationNeedsUpdate = false
    end
end

--------------------------------------------------------------------------------

---@class AmbientLight: Light
local AmbientLight = class('AmbientLight', Light)

function AmbientLight:new(color, intensity)
    return Light.new(self, color, intensity)
end

--------------------------------------------------------------------------------

---@class PointLightShadow
---@field camera PerspectiveCamera
---@field shadowMapAft? ActorFrameTexture

---@class PointLight: Light
---@field position Vec3
---@field castShadows boolean
---@field shadow PointLightShadow
local PointLight = class('PointLight', Light)

function PointLight:new(color, intensity, position)
    local o = Light.new(self, color, intensity, position)
    o.position = position or Vec3:new(0, 0, 0)
    o.castShadows = false
    o.shadow = {
        camera = cameras.PerspectiveCamera:new({
            position = o.position,
            fov = math.rad(90),
            nearDist = 100,
            farDist = 3000,
        })
    }
    return o
end

--------------------------------------------------------------------------------

return {
    AmbientLight = AmbientLight,
    PointLight = PointLight
}