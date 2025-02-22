local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.depthmaterial'
local mixins  = require 'threedee.materials.mixins'

---@class DepthMaterial: Material, WithAlphaMap, WithAlpha
local DepthMaterial = class('DepthMaterial', Material)

DepthMaterial.mixins = {
    mixins.CameraMixin,
    mixins.AlphaMapMixin,
    mixins.AlphaMixin
}

DepthMaterial.vertSource = sources.vert
DepthMaterial.fragSource = sources.frag

function DepthMaterial:onFrameStart(scene)
    Material.onFrameStart(self, scene)
    self.shader:uniform1f('nearDist', scene.camera.nearDist)
    self.shader:uniform1f('farDist', scene.camera.farDist)
end

return DepthMaterial