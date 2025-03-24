local class = require 'threedee.class'
local actors = require 'threedee._actors'
local DepthMaterial = require 'threedee.materials.DepthMaterial'
local cameras = require 'threedee.cameras'
local Updatable = require 'threedee.Updatable'

local standardDepthMat = DepthMaterial:new({
    shader = actors.depthMatActor:GetShader() --[[@as RageShaderProgram]]
})
standardDepthMat.alphaTest = 0.5
standardDepthMat.packingFormat = 'rgb'
---@diagnostic disable-next-line: missing-parameter
standardDepthMat:compile()

---A regular shadow map implementation, using a single camera and an RGB-packed depth format.
---@class StandardShadow: Updatable
---@field camera Camera (Y) The camera used to draw the shadow map. Default: a PerspectiveCamera with all the values set to default.
---@field bias number (U) A bias value to add to a pixel's depth value before testing it against the shadow map. Small negative values can help in mitigating the appearance of strip-like "shadow acne" artifacts, at the cost of causing shadows to appear slightly detached from their casters. Default: `-0.003`
---@field shadowMapAft? ActorFrameTexture (R) The AFT holding the shadow map texture. This starts off as `nil`, with an AFT being assigned to this property only during scene finalization, and only if the shadow is active.
local StandardShadow = class('StandardShadow', Updatable)

---@class StandardShadow.P
---@field camera? Camera
---@field bias? number

---Creates a new StandardShadow. props is a table that contains one or more properties that will be passed into the new StandardShadow; missing properties will be initialized with their defaults.
---
---You likely don't actually need to call this yourself, as lights that support shadows already come with their own instances of StandardShadow, whose properties can be modified for your use.
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

---Called internally to draw the shadow map and save it to self.shadowMapAft.
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

---A StandardShadow with the camera type limited to PerspectiveCamera. Appropriate for PointLights and SpotLights.
---@class StandardPerspectiveShadow: StandardShadow
---@field camera PerspectiveCamera

---A StandardShadow with the camera type limited to OrthographicCamera. Appropriate for DirLights.
---@class StandardOrthographicShadow: StandardShadow
---@field camera OrthographicCamera

return {
    StandardShadow = StandardShadow,
    standardDepthMat = standardDepthMat
}