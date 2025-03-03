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
---@field scene Scene
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

---@param scene Scene
function Light:finalize(scene)
    self.scene = scene
    -- only add the onUpdate method once the scene has been assigned, since
    -- we need scene stuff to run these onUpdate
    self.onUpdate = self._onUpdate
end

---@param props Light.P
function Light:_update(props)
    OrientedObject._update(self, props)
    -- propagate transform changes to the shadow camera
    if self.shadow and (props.position or props.rotation or props.viewMatrix) then
        self.shadow.camera:update({
            position = props.position, -- allowed to be nil
            rotation = props.rotation, -- allowed to be nil
            -- in all transform cases, viewMatrix needs to be updated.
            -- we already have the calculated matrix as self.viewMatrix, so
            -- just pass it in here
            viewMatrix = self.viewMatrix
        })
    end
end

---Once the scene is finalized, this function becomes the onUpdate method
---for this light.
---@param props Light.P
function Light:_onUpdate(props)
end

---@protected
---@param event string
---@param args table
function Light:_dispatchToLightMats(event, args)
    self.scene:_dispatchToLightMats(event, args)
end

--------------------------------------------------------------------------------

---@class AmbientLight: Light
local AmbientLight = class('AmbientLight', Light)

---@class (partial) AmbientLight.P: AmbientLight, Light.P

function AmbientLight:new(color, intensity)
    return Light.new(self, color, intensity)
end

---@type fun(self: AmbientLight, props: AmbientLight.P)
AmbientLight.update = Light.update

---@param props AmbientLight.P
function AmbientLight:_onUpdate(props)
    if props.color or props.intensity then
        -- calculate new ambient light contribution
        local lightColor = Vec3:new(0, 0, 0)
        for _, ambLight in ipairs(self.scene.lights.ambientLights) do
            lightColor:add(ambLight.color:clone():scale(ambLight.intensity))
        end
        self:_dispatchToLightMats('ambientLight', { value = lightColor })
    end
end

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

function PointLight:finalize(scene)
    Light.finalize(self, scene)
    if self.castShadows then
        self.shadow.camera.onUpdate = function(selfC, props)
            local idx = self.index
            ---@cast selfC PerspectiveCamera
            ---@cast props PerspectiveCamera.P
            self:_dispatchToLightMats(
                'pointLightShadowMatrix',
                { index = idx, value = selfC.projMatrix * selfC.viewMatrix }
            )
            if props.nearDist then
                self:_dispatchToLightMats(
                    'pointLightShadowNearDist',
                    { index = idx, value = selfC.nearDist }
                )
            end
            if props.farDist then
                self:_dispatchToLightMats(
                    'pointLightShadowFarDist',
                    { index = idx, value = selfC.farDist }
                )
            end
        end
    end
end

---@type fun(self: PointLight, props: PointLight.P)
PointLight.update = Light.update

---@param props PointLight.P
function PointLight:_onUpdate(props)
    if props.color or props.intensity then
        local col = self.color:clone():scale(self.intensity)
        self:_dispatchToLightMats(
            'pointLightColor',
            { index = self.index, value = col }
        )
    end
    if props.position then
        self:_dispatchToLightMats(
            'pointLightPosition',
            { index = self.index, value = self.position }
        )
    end
end

--------------------------------------------------------------------------------

return {
    AmbientLight = AmbientLight,
    PointLight = PointLight
}