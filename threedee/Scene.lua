local DepthMaterial = require 'threedee.materials.DepthMaterial'
local actors = require 'threedee._actors'
local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'

local depthMat = DepthMaterial:new({
    shader = actors.depthMatActor:GetShader() --[[@as RageShaderProgram]]
})
depthMat.alphaTest = 0.5
---@diagnostic disable-next-line: missing-parameter
depthMat:compile()

for _, shadowMapAft in ipairs(actors.shadowMapAfts) do
    aft(shadowMapAft)
end

---@class SceneLights
---@field ambientLights AmbientLight[]
---@field pointLights PointLight[]
---@field pointLightShadows PointLightShadow[]

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
        ---@cast light PointLight
        table.insert(self.lights.pointLights, light)
        light.index = #self.lights.pointLights - 1
    end
end

function Scene:finalize()
    -- assign onAfterSet functions to camera/lights, so that changes to
    -- camera/lights are sent to the materials that use them

    local lightMaterials = self._lightMaterials
    local cameraMaterials = self._cameraMaterials
    local lights = self.lights

    local function dispatchToLightMats(event, args)
        for _, mat in ipairs(lightMaterials) do
            mat:dispatchEvent(event, args)
        end
    end

    local function dispatchToCameraMats(event, args)
        for _, mat in ipairs(cameraMaterials) do
            mat:dispatchEvent(event, args)
        end
    end

    self.camera.onAfterSet = function(selfC, props)
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

    local function ambientLightOnAfterSet(_, props)
        ---@cast props AmbientLight.P
        if props.color or props.intensity then
            -- calculate new ambient light contribution
            local lightColor = Vec3:new(0, 0, 0)
            for _, ambLight in ipairs(lights.ambientLights) do
                lightColor:add(ambLight.color:clone():scale(ambLight.intensity))
            end
            dispatchToLightMats('ambientLight', { value = lightColor })
        end
    end

    for _, light in ipairs(lights.ambientLights) do
        -- update ambient light uniforms on ambient light change
        light.onAfterSet = ambientLightOnAfterSet
    end

    local function pointLightOnAfterSet(selfL, props)
        ---@cast props PointLight.P
        local idx = selfL.index
        if props.color or props.intensity then
            local col = selfL.color:clone():scale(selfL.intensity)
            dispatchToLightMats(
                'pointLightColor',
                { index = idx, value = col }
            )
        end
        if props.position then
            dispatchToLightMats(
                'pointLightPosition',
                { index = idx, value = props.position }
            )
        end
    end

    for _, light in ipairs(lights.pointLights) do
        light.onAfterSet = pointLightOnAfterSet
        if light.castShadows then
            local idx = #self.lights.pointLightShadows
            table.insert(self.lights.pointLightShadows, light.shadow)
            light.shadow.shadowMapAft = actors.getShadowMapAft()
            light.shadow.index = idx
            light.shadow.camera.onAfterSet = function(selfC, props)
                ---@cast selfC PerspectiveCamera
                ---@cast props PerspectiveCamera.P
                dispatchToLightMats(
                    'pointLightShadowMatrix',
                    { index = idx, value = selfC.projMatrix * selfC.viewMatrix }
                )
                if props.nearDist then
                    dispatchToLightMats(
                        'pointLightShadowNearDist',
                        { index = idx, value = selfC.nearDist }
                    )
                end
                if props.farDist then
                    dispatchToLightMats(
                        'pointLightShadowFarDist',
                        { index = idx, value = selfC.farDist }
                    )
                end
            end
        end
    end

    for _, material in ipairs(self.materials) do
        material:compile(self)
    end
    for _, act in ipairs(self.actors) do
        act:onFinalize(self)
    end
end

function Scene:draw()
    if self._firstDraw then
        for _, material in ipairs(self.materials) do
            material:onBeforeFirstDraw(self)
        end
        depthMat:onBeforeFirstDraw(self)
        self._firstDraw = false
    end

    if self.doShadows then
        -- do shadowmap depth pass

        -- TODO: we probably don't actually need to replace the scene camera anymore?
        local oldCamera = self.camera

        for _, shadow in ipairs(self.lights.pointLightShadows) do
            actors.depthInitQuad:Draw()
            self.camera = shadow.camera
            depthMat:dispatchEvent('cameraReplaced', { camera = self.camera })
            depthMat:onFrameStart(self) -- set nearDist/farDist
            DISPLAY:ShaderFuck(depthMat.shader)
            self._isDrawingShadowMap = true
            self._overrideMaterial = depthMat

            self:drawActors()

            self._isDrawingShadowMap = false
            self._overrideMaterial = nil
            DISPLAY:ClearShaderFuck()

            shadow.shadowMapAft:Draw()
            actors.clearBufferActor:Draw()
        end

        self.camera = oldCamera
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

return Scene