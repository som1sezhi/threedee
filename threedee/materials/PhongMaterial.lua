local Vec3 = require 'threedee.math.Vec3'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.phongmaterial'
local mixins = require 'threedee.materials.mixins'
local materialClass = require 'threedee.materials.materialClass'
local cfs = require 'threedee.materials.changeFuncs'

---@class PhongMaterial: Material, WithCamera, WithColor, WithLights, WithAlpha, WithNormalMap, WithEnvMap
---@field specular Vec3 specular color
---@field specularMap RageTexture|false
---@field specularMapColorSpace 'srgb'|'linear'
---@field emissive Vec3 emissive/ambient color
---@field emissiveMap RageTexture|false
---@field shininess number sharpness of highlight
local PhongMaterial = materialClass('PhongMaterial', Material, {
    mixins.CameraMixin,
    mixins.ColorMixin,
    mixins.LightsMixin,
    mixins.NormalMapMixin,
    mixins.AlphaMixin,
    mixins.EnvMapMixin
})

---@class (partial) PhongMaterial.P: PhongMaterial

PhongMaterial.vertSource = sources.vert
PhongMaterial.fragSource = sources.frag

---@param initProps? PhongMaterial.P
---@return PhongMaterial
function PhongMaterial:new(initProps)
    local o = Material.new(self, initProps)
    o.specular = o.specular or Vec3:new(1, 1, 1)
    o.specularMap = o.specularMap or false
    o.specularMapColorSpace = o.specularMapColorSpace or 'linear'
    o.emissive = o.emissive or Vec3:new(0, 0, 0)
    o.emissiveMap = o.emissiveMap or false
    o.shininess = o.shininess or 32
    return o
end

function PhongMaterial:setDefines(scene)
    Material.setDefines(self, scene)
    self:_defineFlag('USE_SPECULAR_MAP', self.specularMap)
    self:_defineFlag('SPECULAR_MAP_COLORSPACE_SRGB',
        self.specularMapColorSpace == 'srgb'
    )
    self:_defineFlag('USE_EMISSIVE_MAP', self.emissiveMap)
end

---@type fun(self: PhongMaterial, initProps?: PhongMaterial.P)
PhongMaterial.update = Material.update

PhongMaterial.changeFuncs.specular = cfs.vec3ChangeFunc('specular')
PhongMaterial.changeFuncs.specularMap = cfs.optTextureChangeFunc('specularMap')
PhongMaterial.changeFuncs.emissive = cfs.vec3ChangeFunc('emissive')
PhongMaterial.changeFuncs.emissiveMap = cfs.optTextureChangeFunc('emissiveMap')
PhongMaterial.changeFuncs.shininess = cfs.floatChangeFunc('shininess')

return PhongMaterial