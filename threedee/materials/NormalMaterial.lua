local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.normalmaterial'
local mixins  = require 'threedee.materials.mixins'
local materialClass = require 'threedee.materials.materialClass'

---@class NormalMaterial: Material, WithNormalMap, WithAlphaMap, WithAlpha
local NormalMaterial = materialClass('NormalMaterial', Material, {
    mixins.CameraMixin,
    mixins.NormalMapMixin,
    mixins.AlphaMapMixin,
    mixins.AlphaMixin
})

---@class (partial) NormalMaterial.P: NormalMaterial

NormalMaterial.vertSource = sources.vert
NormalMaterial.fragSource = sources.frag

---@type fun(self: NormalMaterial, initProps?: NormalMaterial.P): NormalMaterial
NormalMaterial.new = Material.new

---@type fun(self: NormalMaterial, initProps?: NormalMaterial.P)
NormalMaterial.set = Material.set

return NormalMaterial