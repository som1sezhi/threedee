local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.depthmaterial'

---@class DepthMaterial: Material
local DepthMaterial = class('DepthMaterial', Material)

function DepthMaterial:new(shaderOrActor)
    return Material.new(self, shaderOrActor)
end

function DepthMaterial:compile(scene)
    self.shader:compile(sources.vert, sources.frag)
end

function DepthMaterial:onFrameStart(scene)
    self.shader:uniform3fv('cameraPos', scene.camera.position)
    self.shader:uniformMatrix4fv('tdViewMatrix', scene.camera:getViewMatrix())
    self.shader:uniformMatrix4fv('tdProjMatrix', scene.camera.projMatrix)
    self.shader:uniform1f('nearDist', scene.camera.nearDist)
    self.shader:uniform1f('farDist', scene.camera.farDist)
end

return DepthMaterial