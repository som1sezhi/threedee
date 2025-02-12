local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.normalmaterial'

---@class NormalMaterial: Material
---@field normalMap? RageTexture
local NormalMaterial = class('NormalMaterial', Material)

function NormalMaterial:new(programOrActor)
    return Material.new(self, programOrActor)
end

function NormalMaterial:compile(scene)
    self.program:compile(sources.vert, sources.frag)
    self:_defineFlag('USE_NORMAL_MAP', self.normalMap)
    self.program:compileImmediate()
end

function NormalMaterial:onFrameStart(scene)
    self.program:uniform3fv('cameraPos', scene.camera.position)
    self.program:uniformMatrix4fv('tdViewMatrix', scene.camera.viewMatrix)
    self.program:uniformMatrix4fv('tdProjMatrix', scene.camera.projMatrix)
    if self.normalMap then
        self.program:uniformTexture('normalMap', self.normalMap)
    end
end

return NormalMaterial