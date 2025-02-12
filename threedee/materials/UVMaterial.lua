local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.uvmaterial'

---A debug material that visualizes the UV coordinates on an object.
---@class UVMaterial: Material
local UVMaterial = class('NormalMaterial', Material)

function UVMaterial:new(programOrActor)
    return Material.new(self, programOrActor)
end

function UVMaterial:compile(scene)
    self.program:compile(sources.vert, sources.frag)
end

function UVMaterial:onFrameStart(scene)
    self.program:uniform3fv('cameraPos', scene.camera.position)
    self.program:uniformMatrix4fv('tdViewMatrix', scene.camera.viewMatrix)
    self.program:uniformMatrix4fv('tdProjMatrix', scene.camera.projMatrix)
end

return UVMaterial