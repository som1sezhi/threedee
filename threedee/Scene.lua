local Vec3 = require 'threedee.math.Vec3'
local DepthMaterial = require 'threedee.materials.DepthMaterial'
local NormalMaterial = require 'threedee.materials.NormalMaterial'
local PerspectiveCamera = require 'threedee.Camera'
local ma = require 'threedee.math'
local class = require 'threedee.class'

local depthMat = DepthMaterial:new(_td_depthMatActor)
depthMat:compile()
aft(_td_shadowMapAft)

-- local normalMat = NormalMaterial:new(_td_normalMatActor)
-- normalMat:compile()

---@class DrawContext
---@field isDrawingShadowMap boolean

---@class Scene
---@field aframe ActorFrame
---@field camera PerspectiveCamera
---@field lightPos Vec3
---@field actors SceneActor[]
---@field materials Material[]
---@field doShadows boolean
---@field lightCamera PerspectiveCamera
---@field shadowMap RageTexture
---@field drawContext DrawContext
local Scene = class('Scene')

---@param aframe ActorFrame
---@param camera PerspectiveCamera
---@return Scene
function Scene:new(aframe, camera)
    local pos = Vec3:new(0, -100, 600)
    local o = {
        aframe = aframe,
        camera = camera,

        lightPos = pos,

        actors = {},
        materials = {},

        doShadows = false,
        lightCamera = PerspectiveCamera:new({
            position = pos,
            fov = math.rad(60),
            nearDist = 100,
            farDist = 3100,
        }),
        shadowMap = _td_shadowMapAft:GetTexture(),

        drawContext = {
            isDrawingShadowMap = false
        }
    }
    o = setmetatable(o, self)

    aframe:SetDrawFunction(function()
        o:draw()
    end)

    o.lightCamera:lookAt(Vec3:new(0, 0, 0))

    return o
end

---@param sceneActor SceneActor
function Scene:add(sceneActor)
    table.insert(self.actors, sceneActor)
    if sceneActor.material then
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

function Scene:finalize()
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
        _td_depthInitQuad:Draw()

        local oldCamera = self.camera
        self.camera = self.lightCamera
        depthMat:onFrameStart(self)
        DISPLAY:ShaderFuck(depthMat.program)
        self.drawContext.isDrawingShadowMap = true

        self:drawActors()

        self.drawContext.isDrawingShadowMap = false
        DISPLAY:ClearShaderFuck()
        self.camera = oldCamera

        _td_shadowMapAft:Draw()
        _td_clearBufferActor:Draw()
    end
    for _, material in ipairs(self.materials) do
        material:onFrameStart(self)
    end
    self:drawActors()
end

function Scene:drawActors()
    for _, act in ipairs(self.actors) do
        act.actor:Draw()
    end
end

return Scene