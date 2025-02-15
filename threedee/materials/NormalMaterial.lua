local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.normalmaterial'

---@class NormalMaterial: Material
---@field normalMap? RageTexture
local NormalMaterial = class('NormalMaterial', Material)

function NormalMaterial:new(shaderOrActor)
    return Material.new(self, shaderOrActor)
end

function NormalMaterial:compile(scene)
    self.shader:compile(sources.vert, sources.frag)
    self:_defineFlag('USE_NORMAL_MAP', self.normalMap)
    self.shader:compileImmediate()
end

function NormalMaterial:onFrameStart(scene)
    self.shader:uniform3fv('cameraPos', scene.camera.position)
    self.shader:uniformMatrix4fv('tdViewMatrix', scene.camera:getViewMatrix())
    self.shader:uniformMatrix4fv('tdProjMatrix', scene.camera.projMatrix)
    if self.normalMap then
        self.shader:uniformTexture('normalMap', self.normalMap)
    end
end

return NormalMaterial