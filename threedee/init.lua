local math = require 'threedee.math'
local sceneActors = require 'threedee.SceneActor'

local td = {
    Vec3 = math.Vec3,
    Vec4 = math.Vec4,
    Mat4 = math.Mat4,
    Color = math.Color,

    Scene = require 'threedee.Scene',
    PerspectiveCamera = require 'threedee.Camera',

    ActorWithMaterial = sceneActors.ActorWithMaterial,
    NoteFieldProxy = sceneActors.NoteFieldProxy,

    PhongMaterial = require 'threedee.material.PhongMaterial',
}

return td