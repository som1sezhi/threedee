local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.depthmaterial'

---@class DepthMaterial: Material
local DepthMaterial = class('DepthMaterial', Material)

function DepthMaterial:new(programOrActor)
    return Material.new(self, programOrActor)
end

function DepthMaterial:compile(scene)
    self.program:compile(sources.vert, sources.frag)
end

function DepthMaterial:onFrameStart(scene)
    self.program:uniform3fv('cameraPos', scene.camera.position)
    self.program:uniform3fv('lightPos', scene.lightPos)
    self.program:uniformMatrix4fv('tdViewMatrix', scene.camera.viewMatrix)
    self.program:uniformMatrix4fv('tdProjMatrix', scene.camera.projMatrix)
    self.program:uniform1f('nearDist', scene.camera.nearDist)
    self.program:uniform1f('farDist', scene.camera.farDist)
end

return DepthMaterial