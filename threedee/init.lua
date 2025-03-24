local math = require 'threedee.math'
local sceneActors = require 'threedee.sceneactors'
local cameras = require 'threedee.cameras'
local lights = require 'threedee.lights'

---@class EnvMap
---@field texture RageTexture
---@field mapping 'sphere'|'equirect'
---@field colorFormat 'rgb'
---@field isEnvMap true

---@class (partial) EnvMapArgs: EnvMap
---@field texture RageTexture

---You can use the `td.envMap()` function to help you create EnvMap objects easier. `args` should be a table containing one or more properties that will be passed into the new EnvMap object. The only required property is `.texture`; other properties will be set to their default values if excluded.
---@param args EnvMapArgs
---@return EnvMap
local function envMap(args)
    return {
        texture = args.texture,
        mapping = args.mapping or 'equirect',
        colorFormat = args.colorFormat or 'rgb',
        isEnvMap = true
    }
end

local td = {
    math = math,
    Vec3 = math.Vec3,
    Vec4 = math.Vec4,
    Mat3 = math.Mat3,
    Mat4 = math.Mat4,
    Quat = math.Quat,
    Euler = math.Euler,
    color = math.color,

    Scene = require 'threedee.Scene',

    PerspectiveCamera = cameras.PerspectiveCamera,
    OrthographicCamera = cameras.OrthographicCamera,

    SceneActorFrame = sceneActors.SceneActorFrame,
    MeshActor = sceneActors.MeshActor,
    NoteFieldProxy = sceneActors.NoteFieldProxy,

    Material = require 'threedee.materials.Material',
    PhongMaterial = require 'threedee.materials.PhongMaterial',
    DepthMaterial = require 'threedee.materials.DepthMaterial',
    NormalMaterial = require 'threedee.materials.NormalMaterial',
    UnlitMaterial = require 'threedee.materials.UnlitMaterial',
    UVMaterial = require 'threedee.materials.UVMaterial',
    MatcapMaterial = require 'threedee.materials.MatcapMaterial',

    preprocess = require 'threedee.glsl.preprocess',
    mixins = require 'threedee.materials.mixins',

    AmbientLight = lights.AmbientLight,
    PointLight = lights.PointLight,
    DirLight = lights.DirLight,
    SpotLight = lights.SpotLight,

    envMap = envMap,
}

return td