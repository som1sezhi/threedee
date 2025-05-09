local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.uvmaterial'
local mixins  = require 'threedee.materials.mixins'
local materialClass = require 'threedee.materials.materialClass'

---A debug material that visualizes the UV coordinates on an object using red and green values.
---@class UVMaterial: Material, WithCamera, WithDithering
local UVMaterial = materialClass('UVMaterial', Material, {
    mixins.CameraMixin,
    mixins.DitheringMixin
})

---@class (partial) UVMaterial.P: UVMaterial

UVMaterial.vertSource = sources.vert
UVMaterial.fragSource = sources.frag

---@type fun(self: UVMaterial, initProps?: UVMaterial.P): UVMaterial
UVMaterial.new = Material.new

---@type fun(self: UVMaterial, initProps?: UVMaterial.P)
UVMaterial.update = Material.update

return UVMaterial