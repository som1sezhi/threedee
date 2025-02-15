local math = require 'threedee.math'
local sceneActors = require 'threedee.SceneActor'
local cameras = require 'threedee.cameras'
local lights = require 'threedee.lights'

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

    ActorWithMaterial = sceneActors.ActorWithMaterial,
    NoteFieldProxy = sceneActors.NoteFieldProxy,

    PhongMaterial = require 'threedee.materials.PhongMaterial',
    DepthMaterial = require 'threedee.materials.DepthMaterial',
    NormalMaterial = require 'threedee.materials.NormalMaterial',
    UVMaterial = require 'threedee.materials.UVMaterial',

    AmbientLight = lights.AmbientLight,
    PointLight = lights.PointLight
}

return td