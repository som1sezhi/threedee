local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.phongmaterial'
local mixins = require 'threedee.materials.mixins'
local materialClass = require 'threedee.materials.materialClass'

---@class PhongMaterial: Material, WithColor, WithAlpha, WithNormalMap
---@field specular Vec3 specular color
---@field emissive Vec3 emissive/ambient color
---@field shininess number sharpness of highlight
local PhongMaterial = materialClass('PhongMaterial', Material, {
    mixins.CameraMixin,
    mixins.ColorMixin,
    mixins.LightsMixin,
    mixins.NormalMapMixin,
    mixins.AlphaMixin,
})

---@class (partial) PhongMaterial.P: PhongMaterial

PhongMaterial.vertSource = sources.vert
PhongMaterial.fragSource = sources.frag

---@param initProps? PhongMaterial.P
---@return PhongMaterial
function PhongMaterial:new(initProps)
    local o = Material.new(self, initProps)
    o.specular = Vec3:new(1, 1, 1)
    o.emissive = Vec3:new(0, 0, 0)
    o.shininess = 30
    return o
end

---@type fun(self: PhongMaterial, initProps?: PhongMaterial.P)
PhongMaterial.set = Material.set

function PhongMaterial:onFrameStart(scene)
    Material.onFrameStart(self, scene)
    local sha = self.shader
    sha:uniform3fv('specular', self.specular)
    sha:uniform3fv('emissive', self.emissive)
    sha:uniform1f('shininess', self.shininess)
end

return PhongMaterial