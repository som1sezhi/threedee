local Vec3 = require 'threedee.math.Vec3'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.unlitmaterial'
local mixins = require 'threedee.materials.mixins'
local materialClass = require 'threedee.materials.materialClass'
local cfs = require 'threedee.materials.changeFuncs'

---@class UnlitMaterial: Material, WithCamera, WithColor, WithAlpha
local UnlitMaterial = materialClass('UnlitMaterial', Material, {
    mixins.CameraMixin,
    mixins.ColorMixin,
    mixins.AlphaMixin,
})

---@class (partial) UnlitMaterial.P: UnlitMaterial

UnlitMaterial.vertSource = sources.vert
UnlitMaterial.fragSource = sources.frag

---@type fun(self: UnlitMaterial, initProps?: UnlitMaterial.P): UnlitMaterial
UnlitMaterial.new = Material.new

---@type fun(self: UnlitMaterial, initProps?: UnlitMaterial.P)
UnlitMaterial.set = Material.set

return UnlitMaterial