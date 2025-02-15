local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.depthmaterial'
local mixins  = require 'threedee.materials.mixins'

---@class DepthMaterial: Material
local DepthMaterial = class('DepthMaterial', Material)

DepthMaterial.mixins = {
    mixins.CameraMixin
}

function DepthMaterial:new(shaderOrActor)
    return Material.new(self, shaderOrActor)
end

function DepthMaterial:compile(scene)
    self.shader:compile(sources.vert, sources.frag)
end

function DepthMaterial:onFrameStart(scene)
    Material.onFrameStart(self, scene)
    self.shader:uniform1f('nearDist', scene.camera.nearDist)
    self.shader:uniform1f('farDist', scene.camera.farDist)
end

return DepthMaterial