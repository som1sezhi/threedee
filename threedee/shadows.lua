local class = require 'threedee.class'
local actors = require 'threedee._actors'
local DepthMaterial = require 'threedee.materials.DepthMaterial'
local cameras = require 'threedee.cameras'
local Updatable = require 'threedee.Updatable'

local standardDepthMat = DepthMaterial:new({
    shader = actors.depthMatActor:GetShader() --[[@as RageShaderProgram]]
})
standardDepthMat.alphaTest = 0.5
---@diagnostic disable-next-line: missing-parameter
standardDepthMat:compile()

---A regular shadow map using a single camera and an RGB-packed depth format.
---@class StandardShadow: Updatable
---@field camera Camera
---@field bias number
---@field shadowMapAft? ActorFrameTexture
local StandardShadow = class('StandardShadow', Updatable)

---@class StandardShadow.P
---@field camera? Camera
---@field bias? number

---@param props StandardShadow.P
---@return StandardShadow
function StandardShadow:new(props)
    local o = {
        camera = props.camera or cameras.PerspectiveCamera:new({}),
        bias = -0.003,
    }
    setmetatable(o, StandardShadow)
    return o
end

---@type fun(self: StandardShadow, props: StandardShadow.P)
StandardShadow.update = Updatable.update

---Draws the shadow map and saves it to self.shadowMapAft.
---@param scene Scene
function StandardShadow:drawShadowMap(scene)
    -- init screen with white (max depth)
    actors.depthInitQuad:Draw()

    -- set scene camera to shadowmap camera
    -- (required for standardDepthMat:onFrameStart())
    local oldCamera = scene.camera
    scene.camera = self.camera

    -- set standardDepthMat to use this shadow's camera
    -- TODO: perhaps figure out some way to call this listener through the
    -- pubsub mechanism instead of circumventing it?
    standardDepthMat.listeners['cameraReplaced'](
        standardDepthMat, { camera = self.camera }
    )
    standardDepthMat:onFrameStart(scene) -- set nearDist/farDist

    -- draw shadow map to screen
    DISPLAY:ShaderFuck(standardDepthMat.shader)
    scene._overrideMaterial = standardDepthMat
    scene:drawActors()
    scene._overrideMaterial = nil
    DISPLAY:ClearShaderFuck()

    -- save shadow map to aft
    self.shadowMapAft:Draw()

    scene.camera = oldCamera
end

return {
    StandardShadow = StandardShadow,
    standardDepthMat = standardDepthMat
}