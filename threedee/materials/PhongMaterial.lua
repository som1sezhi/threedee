local Vec3 = require 'threedee.math.Vec3'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.phongmaterial'
local mixins = require 'threedee.materials.mixins'
local materialClass = require 'threedee.materials.materialClass'
local cfs = require 'threedee.materials.changeFuncs'

---@class PhongMaterial: Material, WithCamera, WithColor, WithLights, WithAlpha, WithNormalMap
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
PhongMaterial.update = Material.update

PhongMaterial.changeFuncs.specular = cfs.vec3ChangeFunc('specular')
PhongMaterial.changeFuncs.emissive = cfs.vec3ChangeFunc('emissive')
PhongMaterial.changeFuncs.shininess = cfs.floatChangeFunc('shininess')

return PhongMaterial