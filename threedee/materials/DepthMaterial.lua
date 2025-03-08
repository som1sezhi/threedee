local materialClass = require 'threedee.materials.materialClass'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.depthmaterial'
local mixins  = require 'threedee.materials.mixins'


---@class DepthMaterial: Material, WithCamera, WithAlphaMap, WithAlpha
---@field packingFormat 'none'|'rg'|'rgb'
local DepthMaterial = materialClass('DepthMaterial', Material, {
    mixins.CameraMixin,
    mixins.AlphaMapMixin,
    mixins.AlphaMixin
})

---@class (partial) DepthMaterial.P: DepthMaterial

DepthMaterial.vertSource = sources.vert
DepthMaterial.fragSource = sources.frag

---@param initProps? DepthMaterial.P
---@return DepthMaterial
function DepthMaterial:new(initProps)
    local o = Material.new(self, initProps)
    o.packingFormat = 'none'
    return o
end

function DepthMaterial:setDefines(scene)
    Material.setDefines(self, scene)
    self.shader:define('PACK_FORMAT_' .. string.upper(self.packingFormat))
end

---@type fun(self: DepthMaterial, initProps?: DepthMaterial.P)
DepthMaterial.update = Material.update

function DepthMaterial:onFrameStart(scene)
    Material.onFrameStart(self, scene)
    -- TODO: use event listeners to set these uniforms instead?
    self.shader:uniform1f('nearDist', scene.camera.nearDist)
    self.shader:uniform1f('farDist', scene.camera.farDist)
end

return DepthMaterial