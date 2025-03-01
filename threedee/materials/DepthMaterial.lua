local materialClass = require 'threedee.materials.materialClass'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.depthmaterial'
local mixins  = require 'threedee.materials.mixins'


---@class DepthMaterial: Material, WithAlphaMap, WithAlpha
local DepthMaterial = materialClass('DepthMaterial', Material, {
    mixins.CameraMixin,
    mixins.AlphaMapMixin,
    mixins.AlphaMixin
})

---@class (partial) DepthMaterial.P: DepthMaterial

DepthMaterial.vertSource = sources.vert
DepthMaterial.fragSource = sources.frag

---@type fun(self: DepthMaterial, initProps?: DepthMaterial.P): DepthMaterial
DepthMaterial.new = Material.new

---@type fun(self: DepthMaterial, initProps?: DepthMaterial.P)
DepthMaterial.set = Material.set

function DepthMaterial:onFrameStart(scene)
    Material.onFrameStart(self, scene)
    self.shader:uniform1f('nearDist', scene.camera.nearDist)
    self.shader:uniform1f('farDist', scene.camera.farDist)
end

return DepthMaterial