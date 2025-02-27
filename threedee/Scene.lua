local DepthMaterial = require 'threedee.materials.DepthMaterial'
local actors = require 'threedee._actors'
local class = require 'threedee.class'

local depthMat = DepthMaterial:new(actors.depthMatActor)
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
---@field camera PerspectiveCamera
---@field actors SceneActor[]
---@field materials Material[]
---@field doShadows boolean
---@field lights SceneLights
---@field _isDrawingShadowMap boolean
---@field _overrideMaterial? Material
local Scene = class('Scene')

---@param aframe ActorFrame
---@param camera PerspectiveCamera
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

        drawContext = {
            isDrawingShadowMap = false
        }
    }
    o = setmetatable(o, self)

    aframe:SetDrawFunction(function()
        o:draw()
    end)

    return o
end

---@param sceneActor SceneActor
function Scene:add(sceneActor)
    table.insert(self.actors, sceneActor)
    ---@diagnostic disable-next-line: undefined-field
    if sceneActor.material then
        ---@cast sceneActor (ActorWithMaterial | NoteFieldProxy)
        local shouldAddMaterial = true
        for _, mat in ipairs(self.materials) do
            if mat == sceneActor.material then
                shouldAddMaterial = false
                break
            end
        end
        if shouldAddMaterial then
            table.insert(self.materials, sceneActor.material)
        end
    end
end

---@param light Light
function Scene:addLight(light)
    ---@diagnostic disable-next-line: undefined-field
    local name = light.__name
    if name == 'AmbientLight' then
        table.insert(self.lights.ambientLights, light)
    elseif name == 'PointLight' then
        table.insert(self.lights.pointLights, light)
    end
end

function Scene:finalize()
    local shadowMapAftIdx = 1
    ---@param shadow PointLightShadow
    local function allocShadowMapAft(shadow)
        if shadowMapAftIdx > #actors.shadowMapAfts then
            error('Not enough shadow map AFTs for the number of shadows in the scene. Please add more AFT actors to the _td_shadowMapAft table in threedee.xml.')
        end
        shadow.shadowMapAft = actors.shadowMapAfts[shadowMapAftIdx]
        shadowMapAftIdx = shadowMapAftIdx + 1
    end
    for _, light in ipairs(self.lights.pointLights) do
        if light.castShadows then
            table.insert(self.lights.pointLightShadows, light.shadow)
            allocShadowMapAft(light.shadow)
        end
    end

    for _, material in ipairs(self.materials) do
        material:compile(self)
    end
    for _, act in ipairs(self.actors) do
        act:onFinalize(self)
    end
end

-- function Scene:setShaders()
--     local d = depthMat.program
--     for _, obj in ipairs(self.actors) do
--         if obj.actor.SetTarget == nil then
--         obj.actor:SetShader(d)
--         end
--     end
--     P1:SetArrowShader(d)
--     P1:SetHoldShader(d)
--     P1:SetReceptorShader(d)
-- end

-- function Scene:clearShaders()
--     local pm
--     for _, obj in ipairs(self.actors) do
--         if obj.actor.SetTarget == nil then

--             obj.actor:SetShader(obj.material.program)
--         else
--             pm = obj.material.program
--         end
--     end
--     P1:SetArrowShader(pm)
--     P1:SetHoldShader(pm)
--     P1:SetReceptorShader(pm)
-- end

function Scene:draw()
    if self.doShadows then
        -- do shadowmap depth pass
        local oldCamera = self.camera

        for _, shadow in ipairs(self.lights.pointLightShadows) do
            actors.depthInitQuad:Draw()
            self.camera = shadow.camera
            depthMat:onFrameStart(self)
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