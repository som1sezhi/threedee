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

---@class (partial) Light.P: Light, OrientedObject.P

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

---@param props Light.P
function Light:set(props)
    OrientedObject.set(self, props)
    -- propagate transform changes to the shadow camera
    if self.shadow and (props.position or props.rotation or props.viewMatrix) then
        self.shadow.camera:set({
            position = props.position, -- allowed to be nil
            rotation = props.rotation, -- allowed to be nil
            -- in all transform cases, viewMatrix needs to be updated.
            -- we already have the calculated matrix as self.viewMatrix, so
            -- just pass it in here
            viewMatrix = self.viewMatrix
        })
    end
end

--------------------------------------------------------------------------------

---@class AmbientLight: Light
local AmbientLight = class('AmbientLight', Light)

---@class (partial) AmbientLight.P: AmbientLight, Light.P

function AmbientLight:new(color, intensity)
    return Light.new(self, color, intensity)
end

---@type fun(self: AmbientLight, props: AmbientLight.P)
AmbientLight.set = Light.set

--------------------------------------------------------------------------------

---@class PointLightShadow
---@field index number
---@field camera PerspectiveCamera
---@field shadowMapAft? ActorFrameTexture

---@class PointLight: Light
---@field index number
---@field position Vec3
---@field castShadows boolean
---@field shadow PointLightShadow
local PointLight = class('PointLight', Light)

---@class (partial) PointLight.P: PointLight, Light.P

function PointLight:new(color, intensity, position)
    local o = Light.new(self, color, intensity, position)
    o.index = -1
    o.castShadows = false
    o.shadow = {
        index = -1,
        camera = cameras.PerspectiveCamera:new({
            position = o.position,
            fov = math.rad(90),
            nearDist = 100,
            farDist = 3000,
        })
    }
    return o
end

---@type fun(self: PointLight, props: PointLight.P)
PointLight.set = Light.set

--------------------------------------------------------------------------------

return {
    AmbientLight = AmbientLight,
    PointLight = PointLight
}