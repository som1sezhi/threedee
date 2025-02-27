local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.uvmaterial'
local mixins  = require 'threedee.materials.mixins'

---A debug material that visualizes the UV coordinates on an object.
---@class UVMaterial: Material
local UVMaterial = class('UVMaterial', Material)

---@class (partial) UVMaterial.P: UVMaterial

UVMaterial.mixins = {
    mixins.CameraMixin
}

UVMaterial.vertSource = sources.vert
UVMaterial.fragSource = sources.frag

---@type fun(self: UVMaterial, initProps?: UVMaterial.P): UVMaterial
UVMaterial.new = Material.new

return UVMaterial