local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.normalmaterial'
local mixins  = require 'threedee.materials.mixins'

---@class NormalMaterial: Material
---@field normalMap? RageTexture
local NormalMaterial = class('NormalMaterial', Material)

NormalMaterial.mixins = {
    mixins.CameraMixin,
    mixins.NormalMapMixin
}

function NormalMaterial:new(shaderOrActor)
    return Material.new(self, shaderOrActor)
end

function NormalMaterial:compile(scene)
    self.shader:compile(sources.vert, sources.frag)
    Material.compile(self, scene)
    self.shader:compileImmediate()
end

return NormalMaterial