local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.uvmaterial'
local mixins  = require 'threedee.materials.mixins'

---A debug material that visualizes the UV coordinates on an object.
---@class UVMaterial: Material
local UVMaterial = class('UVMaterial', Material)

UVMaterial.mixins = {
    mixins.CameraMixin
}

function UVMaterial:new(shaderOrActor)
    return Material.new(self, shaderOrActor)
end

function UVMaterial:compile(scene)
    self.shader:compile(sources.vert, sources.frag)
end

function UVMaterial:onFrameStart(scene)
    Material.onFrameStart(self, scene)
end

return UVMaterial