local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.phongmaterial'
local mixins = require 'threedee.materials.mixins'

---@class PhongMaterial: Material
---@field color Vec3 diffuse color
---@field colorMap? RageTexture|'sampler0'
---@field specular Vec3 specular color
---@field emissive Vec3 emissive/ambient color
---@field shininess number sharpness of highlight
---@field normalMap? RageTexture
---@field useVertexColors boolean whether to use vertex colors to modulate the base color
local PhongMaterial = class('PhongMaterial', Material)

PhongMaterial.mixins = {
    mixins.CameraMixin,
    mixins.ColorMixin,
    mixins.LightsMixin,
    mixins.NormalMapMixin,
}

function PhongMaterial:new(shaderOrActor)
    local o = Material.new(self, shaderOrActor)
    o.color = Vec3:new(1, 1, 1)
    o.specular = Vec3:new(1, 1, 1)
    o.emissive = Vec3:new(0, 0, 0)
    o.shininess = 30
    o.useVertexColors = false
    return o
end

function PhongMaterial:compile(scene)
    self.shader:compile(sources.vert, sources.frag)
    Material.compile(self, scene)
    self.shader:compileImmediate()
end

function PhongMaterial:onFrameStart(scene)
    Material.onFrameStart(self, scene)
    local sha = self.shader
    sha:uniform3fv('specular', self.specular)
    sha:uniform3fv('emissive', self.emissive)
    sha:uniform1f('shininess', self.shininess)
end

return PhongMaterial