local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'
local cameras = require 'threedee.cameras'
local OrientedObject = require 'threedee.OrientedObject'
local shadows = require 'threedee.shadows'

local cos = math.cos

---Base class for all lights.
---@class Light: OrientedObject
---@field color Vec3 (U) Light color. Default: `(1, 1, 1)` (white)
---@field intensity number (U) Light intensity (essentially a multiplier for the color). Default: `1`
---@field shadow? StandardShadow
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
function Light:linkWithScene(scene)
    -- implemented by subclass
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

--------------------------------------------------------------------------------

---An ambient light, lighting up all surfaces with a uniform
---color/intensity. Position and rotation is essentially ignored.
---@class AmbientLight: Light
local AmbientLight = class('AmbientLight', Light)

---@class (partial) AmbientLight.P: AmbientLight, Light.P

---Creates a new AmbientLight.
function AmbientLight:new(color, intensity)
    return Light.new(self, color, intensity)
end

function AmbientLight:linkWithScene(scene)
    ---@param props AmbientLight.P
    self.onUpdate = function(self, props)
        if props.color or props.intensity then
            -- calculate new ambient light contribution
            local lightColor = Vec3:new(0, 0, 0)
            for _, ambLight in ipairs(scene.lights.ambientLights) do
                lightColor:add(ambLight.color:clone():scale(ambLight.intensity))
            end
            scene.pub:sendMessage('ambientLight', { value = lightColor })
        end
    end
end

---@type fun(self: AmbientLight, props: AmbientLight.P)
AmbientLight.update = Light.update

--------------------------------------------------------------------------------

---Emits light from a single point in all directions.
---@class PointLight: Light
---@field index number
---@field linearAttenuation number (U) Linear attenuation factor. This value should probably be kept quite small. As you go further from the light, the light dims by a factor of `1 / (1 + linearAttenuation * distance + quadraticAttenuation * distance^2)`. Default: `0`
---@field quadraticAttenuation number (U) Quadratic attenuation factor. This value should porbably be kept quite small. As you go further from the light, the light dims by a factor of `1 / (1 + linearAttenuation * distance + quadraticAttenuation * distance^2)`. Default: `0.000002`
---@field castShadows boolean (X) Whether this light casts shadows. Default: `false`
---@field shadow StandardPerspectiveShadow (Y) The light's shadow. Default: a StandardShadow using a PerspectiveCamera with `.fov = math.rad(90)`, `.nearDist = 100`, and `.farDist = 3000`.
local PointLight = class('PointLight', Light)

---@class (partial) PointLight.P: PointLight, Light.P

---Creates a new PointLight.
function PointLight:new(color, intensity, position)
    local o = Light.new(self, color, intensity, position)
    o.index = -1
    o.linearAttenuation = 0
    o.quadraticAttenuation = 0.000002
    o.castShadows = false
    o.shadow = (shadows.StandardShadow:new{
        camera = cameras.PerspectiveCamera:new({
            position = o.position,
            fov = math.rad(90),
            nearDist = 100,
            farDist = 3000,
        })
    }) --[[@as StandardPerspectiveShadow]]
    return o
end

function PointLight:linkWithScene(scene)
    ---@param props PointLight.P
    self.onUpdate = function(self, props)
        if props.color or props.intensity then
            local col = self.color:clone():scale(self.intensity)
            scene.pub:sendMessage(
                'pointLightProp',
                { self.index, 'vec3', 'color', col }
            )
        end
        if props.position then
            scene.pub:sendMessage(
                'pointLightProp',
                { self.index, 'vec3', 'position', self.position }
            )
        end
        if props.linearAttenuation then
            scene.pub:sendMessage(
                'pointLightProp',
                { self.index, 'float', 'linearAttenuation', self.linearAttenuation }
            )
        end
        if props.quadraticAttenuation then
            scene.pub:sendMessage(
                'pointLightProp',
                { self.index, 'float', 'quadraticAttenuation', self.quadraticAttenuation }
            )
        end
    end

    if self.castShadows then
        ---@param selfS StandardShadow
        ---@param props StandardShadow.P
        self.shadow.onUpdate = function(selfS, props)
            local idx = self.index
            if props.bias then
                scene.pub:sendMessage(
                    'pointLightShadowProp',
                    { idx, 'float', 'bias', selfS.bias }
                )
            end
        end

        ---@param selfC Camera
        ---@param props Camera.P
        self.shadow.camera.onUpdate = function(selfC, props)
            local idx = self.index
            scene.pub:sendMessage(
                'pointLightShadowMatrix',
                { index = idx, value = selfC.projMatrix * selfC.viewMatrix }
            )
            if props.nearDist then
                scene.pub:sendMessage(
                    'pointLightShadowProp',
                    { idx, 'float', 'nearDist', selfC.nearDist }
                )
            end
            if props.farDist then
                scene.pub:sendMessage(
                    'pointLightShadowProp',
                    { idx, 'float', 'farDist', selfC.farDist }
                )
            end
        end
    end
end

---@type fun(self: PointLight, props: PointLight.P)
PointLight.update = Light.update

--------------------------------------------------------------------------------

---Emits light in a single direction. This models a light source that is
---infinitely far away, with light rays going in parallel.
---
---Note that `.position` still matters for this light; if shadows are
---enabled, the light's shadow map will be taken from the POV of that
---position.
---@class DirLight: Light
---@field index number
---@field castShadows boolean (X) Whether this light casts shadows. Default: `false`
---@field shadow StandardOrthographicShadow (Y) The light's shadow. Default: a StandardShadow using an OrthographicCamera with `.nearDist = 100` and `.farDist = 3000`.
local DirLight = class('DirLight', Light)

---@class (partial) DirLight.P: DirLight, Light.P

---Creates a new DirLight.
function DirLight:new(color, intensity)
    local o = Light.new(self, color, intensity)
    o.index = -1
    o.castShadows = false
    o.shadow = (shadows.StandardShadow:new {
        camera = cameras.OrthographicCamera:new({
            nearDist = 100,
            farDist = 3000,
        })
    }) --[[@as StandardOrthographicShadow]]
    return o
end

function DirLight:linkWithScene(scene)
    ---@param props DirLight.P
    self.onUpdate = function(self, props)
        if props.color or props.intensity then
            local col = self.color:clone():scale(self.intensity)
            scene.pub:sendMessage(
                'dirLightProp',
                { self.index, 'vec3', 'color', col }
            )
        end
        if props.rotation then
            local facing = Vec3:new(0, 0, -1):applyQuat(self.rotation)
            scene.pub:sendMessage(
                'dirLightProp',
                { self.index, 'vec3', 'direction', facing }
            )
        end
    end

    if self.castShadows then
        ---@param selfS StandardShadow
        ---@param props StandardShadow.P
        self.shadow.onUpdate = function(selfS, props)
            local idx = self.index
            if props.bias then
                scene.pub:sendMessage(
                    'dirLightShadowProp',
                    { idx, 'float', 'bias', selfS.bias }
                )
            end
        end

        ---@param selfC Camera
        ---@param props Camera.P
        self.shadow.camera.onUpdate = function(selfC, props)
            local idx = self.index
            scene.pub:sendMessage(
                'dirLightShadowMatrix',
                { index = idx, value = selfC.projMatrix * selfC.viewMatrix }
            )
            if props.nearDist then
                scene.pub:sendMessage(
                    'dirLightShadowProp',
                    { idx, 'float', 'nearDist', selfC.nearDist }
                )
            end
            if props.farDist then
                scene.pub:sendMessage(
                    'dirLightShadowProp',
                    { idx, 'float', 'farDist', selfC.farDist }
                )
            end
        end
    end
end

---@type fun(self: DirLight, props: DirLight.P)
DirLight.update = Light.update

--------------------------------------------------------------------------------

---A spotlight, emitting light in a cone pointed in a particular direction.
---@class SpotLight: Light
---@field index number
---@field colorMapIndex number
---@field linearAttenuation number (U) Linear attenuation factor. This value should probably be kept quite small. As you go further from the light, the light dims by a factor of `1 / (1 + linearAttenuation * distance + quadraticAttenuation * distance^2)`. Default: `0`
---@field quadraticAttenuation number (U) Quadratic attenuation factor. This value should probably be kept quite small. As you go further from the light, the light dims by a factor of `1 / (1 + linearAttenuation * distance + quadraticAttenuation * distance^2)`. Default: `0.000002`
---@field castShadows boolean (X) Whether this light casts shadows. Default: `false`
---@field shadow StandardPerspectiveShadow (Y) The light's shadow. Default: a StandardShadow using a PerspectiveCamera with `.fov = light.angle * 2`, `aspectRatio = 1`, `nearDist = 100`, and `farDist = 3000`.
---@field angle number (U) The angular radius of the spotlight, which should be a number in the interval [0, pi/2). Note that updating this property via `:update()` will also update the `.fov` property of this light's shadow camera. Default: `math.rad(45)`
---@field penumbra number (U) A number in [0, 1] representing the proportion of the spotlight radius used to transition between total darkness and full brightness. Lower values give a sharper edge; higher values give a softer edge. Default: `0`
---@field colorMap RageTexture|false (C) If present, this texture is used to modulate the color of the light. This can be used to implement light cookie effects. RGB textures are allowed to be used. Note that the shadow camera's matrices are used to calculate the UV coordinates for this texture, so be aware of this when fiddling with the shadow camera's properties. Default: `false`
local SpotLight = class('SpotLight', Light)

---@class (partial) SpotLight.P: SpotLight, Light.P

---Creates a new SpotLight.
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
    o.colorMapIndex = -1
    o.castShadows = false
    o.linearAttenuation = 0
    o.quadraticAttenuation = 0.000002
    o.angle = angle or math.rad(45)
    o.penumbra = penumbra or 0
    o.shadow = (shadows.StandardShadow:new {
        camera = cameras.PerspectiveCamera:new({
            position = o.position,
            fov = o.angle * 2,
            aspectRatio = 1,
            nearDist = 100,
            farDist = 3000,
        })
    }) --[[@as StandardPerspectiveShadow]]
    o.colorMap = false
    return o
end

function SpotLight:linkWithScene(scene)
    ---@param props SpotLight.P
    self.onUpdate = function(self, props)
        if props.color or props.intensity then
            local col = self.color:clone():scale(self.intensity)
            scene.pub:sendMessage('spotLightProp',
                { self.index, 'vec3', 'color', col }
            )
        end
        if props.position then
            scene.pub:sendMessage('spotLightProp',
                { self.index, 'vec3', 'position', self.position}
            )
        end
        if props.rotation then
            local facing = Vec3:new(0, 0, -1):applyQuat(self.rotation)
            scene.pub:sendMessage('spotLightProp',
                { self.index, 'vec3', 'direction', facing }
            )
        end
        if props.angle then
            local cosInnerAngle = cos(self.angle * (1 - self.penumbra))
            scene.pub:sendMessage('spotLightProp',
                { self.index, 'float', 'cosAngle', cos(self.angle) }
            )
            scene.pub:sendMessage('spotLightProp',
                { self.index, 'float', 'cosInnerAngle', cosInnerAngle }
            )
        elseif props.penumbra then
            local cosInnerAngle = cos(self.angle * (1 - self.penumbra))
            scene.pub:sendMessage('spotLightProp',
                { self.index, 'float', 'cosInnerAngle', cosInnerAngle }
            )
        end
        if props.colorMap then
            scene.pub:sendMessage('spotLightColorMap',
                { index = self.index, value = props.colorMap }
            )
        end
        if props.linearAttenuation then
            scene.pub:sendMessage(
                'spotLightProp',
                { self.index, 'float', 'linearAttenuation', self.linearAttenuation }
            )
        end
        if props.quadraticAttenuation then
            scene.pub:sendMessage(
                'spotLightProp',
                { self.index, 'float', 'quadraticAttenuation', self.quadraticAttenuation }
            )
        end
    end

    ---@param selfC Camera
    ---@param props Camera.P
    self.shadow.camera.onUpdate = function(selfC, props)
        local idx = self.index
        if self.castShadows or self.colorMap then
            scene.pub:sendMessage(
                'spotLightShadowMatrix',
                { index = idx, value = selfC.projMatrix * selfC.viewMatrix }
            )
        end
        if self.castShadows then
            if props.nearDist then
                scene.pub:sendMessage(
                    'spotLightShadowProp',
                    { idx, 'float', 'nearDist', selfC.nearDist }
                )
            end
            if props.farDist then
                scene.pub:sendMessage(
                    'spotLightShadowProp',
                    { idx, 'float', 'farDist', selfC.farDist }
                )
            end
        end
    end

    if self.castShadows then
        ---@param selfS StandardShadow
        ---@param props StandardShadow.P
        self.shadow.onUpdate = function(selfS, props)
            local idx = self.index
            if props.bias then
                scene.pub:sendMessage(
                    'spotLightShadowProp',
                    { idx, 'float', 'bias', selfS.bias }
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

--------------------------------------------------------------------------------

return {
    AmbientLight = AmbientLight,
    PointLight = PointLight,
    DirLight = DirLight,
    SpotLight = SpotLight,
}
