local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'
local cameras = require 'threedee.cameras'
local OrientedObject = require 'threedee.OrientedObject'
local shadows = require 'threedee.shadows'

local cos = math.cos

---Base class for all lights
---@class Light: OrientedObject
---@field color Vec3
---@field intensity number
---@field shadow? StandardShadow
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
    if self.shadow and (props.position or props.rotation or props.viewMatrix or props.shadow) then
        -- propagate transform changes to the shadow camera
        -- or, if the shadow was replaced entirely, propagate the light's transform wholesale
        self.shadow.camera:update({
            position = self.position,
            rotation = self.rotation,
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

---@class PointLight: Light
---@field index number
---@field castShadows boolean
---@field shadow StandardShadow
local PointLight = class('PointLight', Light)

---@class (partial) PointLight.P: PointLight, Light.P

function PointLight:new(color, intensity, position)
    local o = Light.new(self, color, intensity, position)
    o.index = -1
    o.castShadows = false
    o.shadow = shadows.StandardShadow:new{
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
            ---@cast selfC PerspectiveCamera | OrthographicCamera
            ---@cast props PerspectiveCamera.P | OrthographicCamera.P
            self:_dispatchToLightMats(
                'pointLightShadowMatrix',
                { index = idx, value = selfC.projMatrix * selfC.viewMatrix }
            )
            if props.nearDist then
                self:_dispatchToLightMats(
                    'pointLightShadowProp',
                    { idx, 'float', 'nearDist', selfC.nearDist }
                )
            end
            if props.farDist then
                self:_dispatchToLightMats(
                    'pointLightShadowProp',
                    { idx, 'float', 'farDist', selfC.farDist }
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
            'pointLightProp',
            { self.index, 'vec3', 'color', col }
        )
    end
    if props.position then
        self:_dispatchToLightMats(
            'pointLightProp',
            { self.index, 'vec3', 'position', self.position }
        )
    end
end

--------------------------------------------------------------------------------

---@class DirLight: Light
---@field index number
---@field castShadows boolean
---@field shadow StandardShadow
local DirLight = class('DirLight', Light)

---@class (partial) DirLight.P: DirLight, Light.P

function DirLight:new(color, intensity)
    local o = Light.new(self, color, intensity)
    o.index = -1
    o.castShadows = false
    o.shadow = shadows.StandardShadow:new {
        camera = cameras.OrthographicCamera:new({
            nearDist = 100,
            farDist = 3000,
        })
    }
    return o
end

function DirLight:finalize(scene)
    Light.finalize(self, scene)
    if self.castShadows then
        self.shadow.camera.onUpdate = function(selfC, props)
            local idx = self.index
            ---@cast selfC PerspectiveCamera | OrthographicCamera
            ---@cast props PerspectiveCamera.P | OrthographicCamera.P
            self:_dispatchToLightMats(
                'dirLightShadowMatrix',
                { index = idx, value = selfC.projMatrix * selfC.viewMatrix }
            )
            if props.nearDist then
                self:_dispatchToLightMats(
                    'dirLightShadowProp',
                    { idx, 'float', 'nearDist', selfC.nearDist }
                )
            end
            if props.farDist then
                self:_dispatchToLightMats(
                    'dirLightShadowProp',
                    { idx, 'float', 'farDist', selfC.farDist }
                )
            end
        end
    end
end

---@type fun(self: DirLight, props: DirLight.P)
DirLight.update = Light.update

---@param props DirLight.P
function DirLight:_onUpdate(props)
    if props.color or props.intensity then
        local col = self.color:clone():scale(self.intensity)
        self:_dispatchToLightMats(
            'dirLightProp',
            { self.index, 'vec3', 'color', col }
        )
    end
    if props.rotation then
        local facing = Vec3:new(0, 0, -1):applyQuat(self.rotation)
        self:_dispatchToLightMats(
            'dirLightProp',
            { self.index, 'vec3', 'direction', facing }
        )
    end
end

--------------------------------------------------------------------------------

---@class SpotLight: Light
---@field index number
---@field castShadows boolean
---@field shadow StandardShadow
---@field angle number
---@field penumbra number
---@field colorMap RageTexture|false
local SpotLight = class('SpotLight', Light)

---@class (partial) SpotLight.P: SpotLight, Light.P

---@param color? Vec3
---@param intensity? number
---@param position? Vec3
---@param rotation? Quat
---@param angle? number
---@param penumbra? number
---@return SpotLight
function SpotLight:new(color, intensity, position, rotation, angle, penumbra)
    local o = Light.new(self, color, intensity, position, rotation)
    o.index = -1
    o.castShadows = false
    o.angle = angle or math.rad(45)
    o.penumbra = penumbra or 0
    o.shadow = shadows.StandardShadow:new {
        camera = cameras.PerspectiveCamera:new({
            position = o.position,
            fov = o.angle * 2,
            aspectRatio = 1,
            nearDist = 100,
            farDist = 3000,
        })
    }
    o.colorMap = false
    return o
end

function SpotLight:finalize(scene)
    Light.finalize(self, scene)
    if self.castShadows then
        self.shadow.camera.onUpdate = function(selfC, props)
            local idx = self.index
            ---@cast selfC PerspectiveCamera | OrthographicCamera
            ---@cast props PerspectiveCamera.P | OrthographicCamera.P
            self:_dispatchToLightMats(
                'spotLightShadowMatrix',
                { index = idx, value = selfC.projMatrix * selfC.viewMatrix }
            )
            if props.nearDist then
                self:_dispatchToLightMats(
                    'spotLightShadowProp',
                    { idx, 'float', 'nearDist', selfC.nearDist }
                )
            end
            if props.farDist then
                self:_dispatchToLightMats(
                    'spotLightShadowProp',
                    { idx, 'float', 'farDist', selfC.farDist }
                )
            end
        end
    end
end

---@type fun(self: SpotLight, props: SpotLight.P)
SpotLight.update = Light.update

---@param props SpotLight.P
function SpotLight:_update(props)
    Light._update(self, props)
    if props.angle then
        self.shadow.camera:update({
            fov = self.angle * 2
        })
    end
end

---@param props SpotLight.P
function SpotLight:_onUpdate(props)
    if props.color or props.intensity then
        local col = self.color:clone():scale(self.intensity)
        self:_dispatchToLightMats('spotLightProp',
            { self.index, 'vec3', 'color', col }
        )
    end
    if props.position then
        self:_dispatchToLightMats('spotLightProp',
            { self.index, 'vec3', 'position', self.position}
        )
    end
    if props.rotation then
        local facing = Vec3:new(0, 0, -1):applyQuat(self.rotation)
        self:_dispatchToLightMats('spotLightProp',
            { self.index, 'vec3', 'direction', facing }
        )
    end
    if props.angle then
        local cosInnerAngle = cos(self.angle * (1 - self.penumbra))
        self:_dispatchToLightMats('spotLightProp',
            { self.index, 'float', 'cosAngle', cos(self.angle) }
        )
        self:_dispatchToLightMats('spotLightProp',
            { self.index, 'float', 'cosInnerAngle', cosInnerAngle }
        )
    elseif props.penumbra then
        local cosInnerAngle = cos(self.angle * (1 - self.penumbra))
        self:_dispatchToLightMats('spotLightProp',
            { self.index, 'float', 'cosInnerAngle', cosInnerAngle }
        )
    end
    if props.colorMap then
        self:_dispatchToLightMats('spotLightColorMap',
            { index = self.index, value = props.colorMap }
        )
    end
end

--------------------------------------------------------------------------------

return {
    AmbientLight = AmbientLight,
    PointLight = PointLight,
    DirLight = DirLight,
    SpotLight = SpotLight,
}
