local DepthMaterial = require 'threedee.materials.DepthMaterial'
local actors = require 'threedee._actors'
local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'
local shadows = require 'threedee.shadows'

---@class SceneLights
---@field ambientLights AmbientLight[]
---@field pointLights PointLight[]
---@field pointLightShadows StandardShadow[]
---@field dirLights DirLight[]
---@field dirLightShadows StandardShadow[]

---@class Scene
---@field aframe ActorFrame
---@field camera Camera
---@field actors SceneActor[]
---@field materials Material[]
---@field doShadows boolean
---@field lights SceneLights
---@field _isDrawingShadowMap boolean
---@field _overrideMaterial? Material
---@field private _firstDraw boolean
---@field private _lightMaterials Material[]
---@field private _cameraMaterials Material[]
local Scene = class('Scene')

---@param aframe ActorFrame
---@param camera Camera
---@return Scene
function Scene:new(aframe, camera)
    local o = {
        aframe = aframe,
        camera = camera,

        actors = {},
        materials = {},

        doShadows = false,
        lights = {
            ambientLights = {},
            pointLights = {},
            pointLightShadows = {},
            dirLights = {},
            dirLightShadows = {},
        },


        _isDrawingShadowMap = false,
        _firstDraw = true,
        _lightMaterials = {},
        _cameraMaterials = {}
    }
    o = setmetatable(o, self)

    aframe:SetDrawFunction(function()
        o:draw()
    end)

    return o
end

---@private
function Scene:_addMaterialsFromSceneActor(sceneActor)
    if sceneActor.material then
        -- this is an ActorWithMaterial
        local material = sceneActor.material
        -- don't add material if already in material tables
        local shouldAddMaterial = true
        for _, mat in ipairs(self.materials) do
            if mat == material then
                shouldAddMaterial = false
                break
            end
        end
        -- add to material tables
        if shouldAddMaterial then
            table.insert(self.materials, material)
            if material.useCamera then
                table.insert(self._cameraMaterials, material)
            end
            if material.useLights then
                table.insert(self._lightMaterials, material)
            end
        end
    elseif sceneActor.children then
        -- this is a SceneActorFrame, add children's materials
        for _, child in ipairs(sceneActor.children) do
            self:_addMaterialsFromSceneActor(child)
        end
    end
end

---@param sceneActor SceneActor
function Scene:add(sceneActor)
    table.insert(self.actors, sceneActor)
    self:_addMaterialsFromSceneActor(sceneActor)
end

---@param light Light
function Scene:addLight(light)
    ---@diagnostic disable-next-line: undefined-field
    local name = light.__name
    if name == 'AmbientLight' then
        table.insert(self.lights.ambientLights, light)
    elseif name == 'PointLight' then
        table.insert(self.lights.pointLights, light)
    elseif name == 'DirLight' then
        table.insert(self.lights.dirLights, light)
    end
end

function Scene:finalize()
    -- assign onAfterSet functions to camera/lights, so that changes to
    -- camera/lights are sent to the materials that use them

    local cameraMaterials = self._cameraMaterials
    local lights = self.lights

    local function dispatchToCameraMats(event, args)
        for _, mat in ipairs(cameraMaterials) do
            mat:dispatchEvent(event, args)
        end
    end

    self.camera.onUpdate = function(selfC, props)
        ---@cast selfC Camera
        ---@cast props PerspectiveCamera.P
        if props.position then
            dispatchToCameraMats('cameraPos', { value = props.position })
        end
        if props.position or props.rotation or props.viewMatrix then
            dispatchToCameraMats('viewMatrix', { value = selfC.viewMatrix })
        end
        ---@diagnostic disable-next-line: invisible
        if selfC._projMatWasUpdated then
            dispatchToCameraMats('projMatrix', { value = selfC.projMatrix })
            ---@diagnostic disable-next-line: invisible
            selfC._projMatWasUpdated = false
        end
    end

    -- sort such that shadow-casting lights come first
    local function sortFunc(a, b) return a.castShadows end
    table.sort(lights.pointLights, sortFunc)
    table.sort(lights.dirLights, sortFunc)

    for _, light in ipairs(lights.ambientLights) do
        light:finalize(self)
    end
    for i, light in ipairs(lights.pointLights) do
        light.index = i - 1
        light:finalize(self)
        if light.castShadows then
            table.insert(self.lights.pointLightShadows, light.shadow)
            light.shadow.shadowMapAft = actors.getShadowMapAft()
        end
    end
    for i, light in ipairs(lights.dirLights) do
        light.index = i - 1
        light:finalize(self)
        if light.castShadows then
            table.insert(self.lights.dirLightShadows, light.shadow)
            light.shadow.shadowMapAft = actors.getShadowMapAft()
        end
    end

    for _, material in ipairs(self.materials) do
        material:compile(self)
    end
    for _, act in ipairs(self.actors) do
        act:finalize(self)
    end
end

function Scene:draw()
    if self._firstDraw then
        for _, material in ipairs(self.materials) do
            material:onBeforeFirstDraw(self)
        end
        shadows.standardDepthMat:onBeforeFirstDraw(self)
        self._firstDraw = false
    end

    if self.doShadows then
        -- do shadowmap depth pass
        self._isDrawingShadowMap = true
        for _, shadow in ipairs(self.lights.pointLightShadows) do
            shadow:drawShadowMap(self)
        end
        for _, shadow in ipairs(self.lights.dirLightShadows) do
            shadow:drawShadowMap(self)
        end
        self._isDrawingShadowMap = false
        actors.clearBufferActor:Draw()
    end

    for _, material in ipairs(self.materials) do
        material:onFrameStart(self)
    end
    self:drawActors()
end

function Scene:drawActors()
    for _, act in ipairs(self.actors) do
        act:Draw()
    end
end

---@param event string
---@param args table
function Scene:_dispatchToLightMats(event, args)
    for _, mat in ipairs(self._lightMaterials) do
        mat:dispatchEvent(event, args)
    end
end

return Scene