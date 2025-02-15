local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.uvmaterial'

---A debug material that visualizes the UV coordinates on an object.
---@class UVMaterial: Material
local UVMaterial = class('NormalMaterial', Material)

function UVMaterial:new(shaderOrActor)
    return Material.new(self, shaderOrActor)
end

function UVMaterial:compile(scene)
    self.shader:compile(sources.vert, sources.frag)
end

function UVMaterial:onFrameStart(scene)
    self.shader:uniform3fv('cameraPos', scene.camera.position)
    self.shader:uniformMatrix4fv('tdViewMatrix', scene.camera:getViewMatrix())
    self.shader:uniformMatrix4fv('tdProjMatrix', scene.camera.projMatrix)
end

return UVMaterial