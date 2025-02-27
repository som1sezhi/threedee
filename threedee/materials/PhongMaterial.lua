local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.phongmaterial'
local mixins = require 'threedee.materials.mixins'

---@class PhongMaterial: Material, WithColor, WithAlpha, WithNormalMap
---@field specular Vec3 specular color
---@field emissive Vec3 emissive/ambient color
---@field shininess number sharpness of highlight
local PhongMaterial = class('PhongMaterial', Material)

PhongMaterial.mixins = {
    mixins.CameraMixin,
    mixins.ColorMixin,
    mixins.LightsMixin,
    mixins.NormalMapMixin,
    mixins.AlphaMixin,
}

PhongMaterial.vertSource = sources.vert
PhongMaterial.fragSource = sources.frag

function PhongMaterial:new()
    local o = Material.new(self)
    o.specular = Vec3:new(1, 1, 1)
    o.emissive = Vec3:new(0, 0, 0)
    o.shininess = 30
    return o
end

function PhongMaterial:onFrameStart(scene)
    Material.onFrameStart(self, scene)
    local sha = self.shader
    sha:uniform3fv('specular', self.specular)
    sha:uniform3fv('emissive', self.emissive)
    sha:uniform1f('shininess', self.shininess)
end

return PhongMaterial