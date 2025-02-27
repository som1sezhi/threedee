local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.normalmaterial'
local mixins  = require 'threedee.materials.mixins'

---@class NormalMaterial: Material, WithNormalMap, WithAlphaMap, WithAlpha
local NormalMaterial = class('NormalMaterial', Material)

NormalMaterial.mixins = {
    mixins.CameraMixin,
    mixins.NormalMapMixin,
    mixins.AlphaMapMixin,
    mixins.AlphaMixin
}

NormalMaterial.vertSource = sources.vert
NormalMaterial.fragSource = sources.frag

return NormalMaterial