local actors = require 'threedee._actors'
local class = require 'threedee.class'
local shadows = require 'threedee.shadows'
local BackgroundMaterial = require 'threedee.materials.BackgroundMaterial'
local Vec3 = require 'threedee.math.Vec3'
local Mat3 = require 'threedee.math.Mat3'
local sceneActors = require 'threedee.sceneactors'
local Updatable = require 'threedee.Updatable'
local PubSub = require 'threedee.PubSub'

---@class SceneLights
---@field ambientLights AmbientLight[]
---@field pointLights PointLight[]
---@field pointLightShadows StandardShadow[]
---@field dirLights DirLight[]
---@field dirLightShadows StandardShadow[]
---@field spotLights SpotLight[]
---@field spotLightShadows StandardShadow[]
---@field numSpotLightColorMaps number
---@field numSpotLightMatrices number

---@class Scene: Updatable
---@field aframe ActorFrame (R) The scene ActorFrame.
---@field camera Camera (Y) The camera used to draw the scene.
---@field actors SceneActor[] (R) The scene's actors.
---@field materials Material[] (R) The scene's materials.
---@field lights SceneLights
---@field pub PubSub
---@field doShadows boolean (U) Global toggle for shadows. Default: `true`
---@field shadowMapFilter 'none'|'pcf_simple'|'pcf_bilinear' (X) The kind of filtering applied to the shadow map when using shadows. In order of increasing visual quality (and cost): `'none'` does no filtering and can result in jagged-looking shadows; `'pcf_simple'` does percentage-closer filtering (PCF) with a 3x3 neighborhood of texels; and `'pcf_bilinear'` does PCF with a 3x3 grid of bilinear samples using data from a 4x4 neighborhood of texels. Default: `'pcf_simple'`
---@field background Vec3|RageTexture|EnvMap (C) The scene background. If set to a Vec3 (i.e. a color), a solid-color background will be drawn. If set to a RageTexture, a static full-screen image will be drawn. If set to an EnvMap, a 3D environment map will be drawn. Default: `(0, 0, 0)` (black)
---@field backgroundRotation Mat3 (U) The environment map rotation, if using an environment map for the background. Default: identity matrix
---@field backgroundIntensity number (U) The background brightness. Default: `1`
---@field drawBackgroundFirst boolean (U) If true, draw the background first, before any of the scene's actors; if false, draw the background last. Setting this to false is slightly more performant (no time wasted drawing parts of the background that would be covered up), but may lead to z-buffer issues with notefield receptors if the receptors are positioned directly on top of the background. Default: `true`
---@field _isDrawingShadowMap boolean
---@field _overrideMaterial? Material
---@field private _firstDraw boolean
---@field private _backgroundMaterial BackgroundMaterial
---@field private _backgroundActor MeshActor
local Scene = class('Scene', Updatable)

---Creates a new scene with the given ActorFrame and Camera.
---@param aframe ActorFrame
---@param camera Camera
---@return Scene
function Scene:new(aframe, camera)
    local bgMat = BackgroundMaterial:new()
    local o = {
        aframe = aframe,
        camera = camera,

        actors = {},
        materials = {},
        lights = {
            ambientLights = {},
            pointLights = {},
            pointLightShadows = {},
            dirLights = {},
            dirLightShadows = {},
            spotLights = {},
            spotLightShadows = {},
            numSpotLightColorMaps = 0,
            numSpotLightMatrices = 0
        },

        pub = PubSub:new(),

        doShadows = true,
        shadowMapFilter = 'pcf_simple',
        background = Vec3:new(0, 0, 0),
        backgroundRotation = Mat3:new(),
        backgroundIntensity = 1,
        drawBackgroundFirst = true,

        _isDrawingShadowMap = false,
        _firstDraw = true,
        _backgroundMaterial = bgMat,
        _backgroundActor = sceneActors.MeshActor:new(actors.cubeModel, bgMat)
    }
    o = setmetatable(o, self)

    aframe:SetDrawFunction(function()
        o:draw()
    end)

    return o
end

---@private
function Scene:_addMaterial(material)
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
    end
end

---@private
function Scene:_addMaterialsFromSceneActor(sceneActor)
    if sceneActor.material then
        -- this is an ActorWithMaterial
        self:_addMaterial(sceneActor.material)
        if sceneActor.__name == 'NoteFieldProxy' then
            ---@cast sceneActor NoteFieldProxy
            if sceneActor.arrowMaterial then
                self:_addMaterial(sceneActor.arrowMaterial)
            end
            if sceneActor.holdMaterial then
                self:_addMaterial(sceneActor.holdMaterial)
            end
            if sceneActor.receptorMaterial then
                self:_addMaterial(sceneActor.receptorMaterial)
            end
            if sceneActor.arrowPathMaterial then
                self:_addMaterial(sceneActor.arrowPathMaterial)
            end
        end
    elseif sceneActor.children then
        -- this is a SceneActorFrame, add children's materials
        for _, child in ipairs(sceneActor.children) do
            self:_addMaterialsFromSceneActor(child)
        end
    end
end

---Adds a new actor to the scene. The SceneActor should wrap a direct
---child of `self.aframe`.
---@param sceneActor SceneActor
function Scene:add(sceneActor)
    table.insert(self.actors, sceneActor)
    self:_addMaterialsFromSceneActor(sceneActor)
end

---Adds a light to the scene.
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
    elseif name == 'SpotLight' then
        table.insert(self.lights.spotLights, light)
    end
end

---Finalizes the scene. This compiles all the materials' shaders and
---does some other other bookkeeping work. After calling this, many
---properties of the Scene/SceneActors/lights/materials/etc. are effectively
---"frozen" and should not be changed. For example, you may not add
---any more actors or lights to the scene after calling this.
function Scene:finalize()
    local lights = self.lights

    self.camera:linkWithScene(self)

    -- sort such that shadow-casting lights come first
    local function sortFunc(a, b) return a.castShadows and not b.castShadows end
    table.sort(lights.pointLights, sortFunc)
    table.sort(lights.dirLights, sortFunc)
    -- sort spotlights with colormaps first
    table.sort(lights.spotLights, function(a, b)
        if a.castShadows == b.castShadows then
            return (a.colorMap and not b.colorMap) and true or false
        end
        return a.castShadows
    end)

    -- collect counts
    for i, light in ipairs(lights.spotLights) do
        if not (light.colorMap or light.castShadows) then break end
        if light.colorMap then
            lights.numSpotLightColorMaps = lights.numSpotLightColorMaps + 1
        end
        lights.numSpotLightMatrices = i
    end

    for _, light in ipairs(lights.ambientLights) do
        light:linkWithScene(self)
    end
    for i, light in ipairs(lights.pointLights) do
        light.index = i - 1
        light:linkWithScene(self)
        if light.castShadows then
            table.insert(self.lights.pointLightShadows, light.shadow)
            light.shadow.shadowMapAft = actors.getShadowMapAft()
        end
    end
    for i, light in ipairs(lights.dirLights) do
        light.index = i - 1
        light:linkWithScene(self)
        if light.castShadows then
            table.insert(self.lights.dirLightShadows, light.shadow)
            light.shadow.shadowMapAft = actors.getShadowMapAft()
        end
    end
    local colorMapIndex = 0
    for i, light in ipairs(lights.spotLights) do
        light.index = i - 1
        light:linkWithScene(self)
        if light.castShadows then
            table.insert(self.lights.spotLightShadows, light.shadow)
            light.shadow.shadowMapAft = actors.getShadowMapAft()
        end
        if light.colorMap then
            light.colorMapIndex = colorMapIndex
            colorMapIndex = colorMapIndex + 1
        end
    end

    for _, material in ipairs(self.materials) do
        material:compile(self)
    end
    for _, act in ipairs(self.actors) do
        act:finalize(self)
    end

    local bg = self.background
    ---@diagnostic disable-next-line: undefined-field
    if bg.__name == 'Vec3' then
        ---@cast bg Vec3
        self._backgroundMaterial.color = bg
    elseif bg.isEnvMap then
        ---@cast bg EnvMap
        self._backgroundMaterial.envMap = bg
    else
        ---@cast bg RageTexture
        self._backgroundMaterial.colorMap = bg
    end
    self._backgroundMaterial.envMapRotation = self.backgroundRotation
    self._backgroundMaterial.intensity = self.backgroundIntensity
    self._backgroundMaterial:compile(self)
    self._backgroundActor:finalize(self)
end

---This is the method called internally by the scene ActorFrame's
---drawfunction to draw the scene.
function Scene:draw()
    if self._firstDraw then
        -- ensure camera matrices are updated
        self.camera:updateViewMatrix()
        self.camera:updateProjMatrix()

        -- ensure lights' matrices are updated
        -- these update calls should also update the light's shadow camera
        for _, light in ipairs(self.lights.pointLights) do
            light:update({ position = light.position, rotation = light.rotation })
        end
        for _, light in ipairs(self.lights.dirLights) do
            light:update({ position = light.position, rotation = light.rotation })
        end
        for _, light in ipairs(self.lights.spotLights) do
            light:update({ position = light.position, rotation = light.rotation })
        end
        -- we still need to ensure the projection matrices for the shadow cameras
        -- are updated though
        for _, shadow in ipairs(self.lights.pointLightShadows) do
            shadow.camera:updateProjMatrix()
        end
        for _, shadow in ipairs(self.lights.dirLightShadows) do
            shadow.camera:updateProjMatrix()
        end
        for _, shadow in ipairs(self.lights.spotLightShadows) do
            shadow.camera:updateProjMatrix()
        end

        -- ensure materials are ready
        for _, material in ipairs(self.materials) do
            material:onBeforeFirstDraw(self)
        end
        shadows.standardDepthMat:onBeforeFirstDraw(self) -- TODO: is this correct?
        self._backgroundMaterial:onBeforeFirstDraw(self)
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
        for _, shadow in ipairs(self.lights.spotLightShadows) do
            shadow:drawShadowMap(self)
        end
        self._isDrawingShadowMap = false
        actors.clearBufferActor:Draw()
    end

    for _, material in ipairs(self.materials) do
        material:onFrameStart(self)
    end
    self._backgroundMaterial:onFrameStart(self)
    if self.drawBackgroundFirst then
        self._backgroundActor:Draw()
    end
    self:drawActors()
    if not self.drawBackgroundFirst then
        self._backgroundActor:Draw()
    end
    
end

---Calls all the scene actors' `:Draw()` methods once.
---You can override this method to set your own scene "drawfunction", similar
---to what you might usually use NotITG drawfunctions for (e.g. to draw
---the same actor multiple times per frame). Make sure to call the `:Draw()`
---methods on the SceneActors instead of the bare, unwrapped actors.
function Scene:drawActors()
    for _, act in ipairs(self.actors) do
        act:Draw()
    end
end

---@class Scene.P
---@field doShadows? boolean
---@field background? Vec3|RageTexture|EnvMap
---@field backgroundRotation? Mat3
---@field backgroundIntensity? number

---@type fun(self: Scene, props: Scene.P)
Scene.update = Updatable.update

---@param props Scene.P
function Scene:_update(props)
    Updatable._update(self, props)

    local bg = props.background
    if bg then
        ---@diagnostic disable-next-line: undefined-field
        if bg.__name == 'Vec3' then
            ---@cast bg Vec3
            self._backgroundMaterial:update{ color = bg }
        elseif bg.isEnvMap then
            ---@cast bg EnvMap
            self._backgroundMaterial:update{ envMap = bg }
        else
            ---@cast bg RageTexture
            self._backgroundMaterial:update{ colorMap = bg }
        end
    end
    if props.backgroundRotation then
        self._backgroundMaterial:update{
            envMapRotation = self.backgroundRotation
        }
    end
    if props.backgroundIntensity then
        self._backgroundMaterial:update{
            intensity = self.backgroundIntensity
        }
    end
end

return Scene