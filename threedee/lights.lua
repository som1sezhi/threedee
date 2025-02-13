local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'
local cameras = require 'threedee.cameras'

---Base class for all lights
---@class Light
---@field color Vec3
---@field intensity number
local Light = class('Light')

---@generic L: Light
---@param self L
---@param color? Vec3
---@param intensity? number
---@return L
function Light.new(self, color, intensity)
    return setmetatable({
        color = color or Vec3:new(1, 1, 1),
        intensity = intensity or 1
    }, self)
end

--------------------------------------------------------------------------------

---@class AmbientLight: Light
local AmbientLight = class('AmbientLight', Light)

--------------------------------------------------------------------------------

---@class PointLightShadow
---@field camera PerspectiveCamera
---@field shadowMapAft? ActorFrameTexture

---@class PointLight: Light
---@field position Vec3
---@field castShadows boolean
---@field shadow PointLightShadow
local PointLight = class('PointLight', Light)

---@param color? Vec3
---@param intensity? number
---@param position? Vec3
---@return PointLight
function PointLight:new(color, intensity, position)
    local o = Light.new(self, color, intensity)
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

return {
    AmbientLight = AmbientLight,
    PointLight = PointLight
}