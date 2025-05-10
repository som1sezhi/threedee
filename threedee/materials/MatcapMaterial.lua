local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.matcapmaterial'
local mixins  = require 'threedee.materials.mixins'
local materialClass = require 'threedee.materials.materialClass'
local cfs = require 'threedee.materials.changeFuncs'

---A material that uses a matcap texture to give an appearance of lighting/shading.
---@class MatcapMaterial: Material, WithCamera, WithNormalMap, WithColor, WithAlpha, WithDithering
---@field matcap RageTexture|false (C) The matcap texture. Default: `false`
local MatcapMaterial = materialClass('MatcapMaterial', Material, {
    mixins.CameraMixin,
    mixins.NormalMapMixin,
    mixins.ColorMixin,
    mixins.AlphaMixin,
    mixins.DitheringMixin
})

---@class (partial) MatcapMaterial.P: MatcapMaterial

MatcapMaterial.vertSource = sources.vert
MatcapMaterial.fragSource = sources.frag

---@type fun(self: MatcapMaterial, initProps?: MatcapMaterial.P): MatcapMaterial
function MatcapMaterial:new(initProps)
    local o = Material.new(self, initProps)
    o.matcap = o.matcap or false
    return o
end

function MatcapMaterial:setDefines(scene)
    Material.setDefines(self, scene)
    self:_defineFlag('USE_MATCAP', self.matcap)
end

---@type fun(self: MatcapMaterial, initProps?: MatcapMaterial.P)
MatcapMaterial.update = Material.update

MatcapMaterial.changeFuncs['matcap'] = cfs.optTextureChangeFunc('matcap')

return MatcapMaterial