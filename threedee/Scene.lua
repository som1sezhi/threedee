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
---@field aframe ActorFrame
---@field camera Camera
---@field actors SceneActor[]
---@field materials Material[]
---@field lights SceneLights
---@field pub PubSub
---@field doShadows boolean
---@field shadowMapFilter 'none'|'pcf_simple'|'pcf_bilinear'
---@field background Vec3|RageTexture|EnvMap
---@field backgroundRotation Mat3
---@field backgroundIntensity number
---@field drawBackgroundFirst boolean
---@field _isDrawingShadowMap boolean
---@field _overrideMaterial? Material
---@field private _firstDraw boolean
---@field private _backgroundMaterial BackgroundMaterial
---@field private _backgroundActor MeshActor
local Scene = class('Scene', Updatable)

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

        doShadows = false,
        shadowMapFilter = 'pcf_simple',
        background = Vec3:new(0, 0, 0),
        backgroundRotation = Mat3:new(),
        backgroundIntensity = 1,
        drawBackgroundFirst = false,

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
    elseif name == 'SpotLight' then
        table.insert(self.lights.spotLights, light)
    end
end

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

function Scene:draw()
    if self._firstDraw then
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