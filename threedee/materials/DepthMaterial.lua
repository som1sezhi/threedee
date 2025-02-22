local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.depthmaterial'
local mixins  = require 'threedee.materials.mixins'

---@class DepthMaterial: Material
---@field alphaMap? RageTexture|'sampler0'
---@field useVertexColors boolean
---@field transparent boolean
---@field opacity number
---@field alphaTest number
---@field alphaHash boolean
local DepthMaterial = class('DepthMaterial', Material)

DepthMaterial.mixins = {
    mixins.CameraMixin,
    mixins.AlphaMapMixin,
    mixins.AlphaMixin
}

function DepthMaterial:new(shaderOrActor)
    local o = Material.new(self, shaderOrActor)
    o.useVertexColors = false
    o.transparent = false
    o.opacity = 1
    o.alphaTest = 0.001
    o.alphaHash = false
    return o
end

function DepthMaterial:compile(scene)
    self.shader:compile(sources.vert, sources.frag)
    Material.compile(self, scene)
    self.shader:compileImmediate()
end

function DepthMaterial:onFrameStart(scene)
    Material.onFrameStart(self, scene)
    self.shader:uniform1f('nearDist', scene.camera.nearDist)
    self.shader:uniform1f('farDist', scene.camera.farDist)
end

return DepthMaterial