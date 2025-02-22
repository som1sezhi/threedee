local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.depthmaterial'
local mixins  = require 'threedee.materials.mixins'

---@class DepthMaterial: Material
---@field alphaMap? RageTexture|'sampler0'
---@field useVertexColors boolean
local DepthMaterial = class('DepthMaterial', Material)

DepthMaterial.mixins = {
    mixins.CameraMixin,
    mixins.AlphaMapMixin
}

function DepthMaterial:new(shaderOrActor)
    local o = Material.new(self, shaderOrActor)
    o.useVertexColors = false
    return o
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