local Color = require 'threedee.math.Color'
local class = require 'threedee.class'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.phongmaterial'

---@class PhongMaterial: Material
---@field diffuse Color diffuse color
---@field diffuseMap? RageTexture|'sampler0'
---@field specular Color specular color
---@field emissive Color emissive/ambient color
---@field shininess number sharpness of highlight
---@field normalMap? RageTexture
---@field useVertexColors boolean whether to use vertex colors to modulate the base color
local PhongMaterial = class('PhongMaterial', Material)

function PhongMaterial:new(programOrActor)
    local o = Material.new(self, programOrActor)
    o.diffuse = Color:new(1, 1, 1)
    o.specular = Color:new(1, 1, 1)
    o.emissive = Color:new(0, 0, 0)
    o.shininess = 30
    o.useVertexColors = false
    return o
end

function PhongMaterial:compile(scene)
    self.program:compile(sources.vert, sources.frag)
    self:_defineFlag('USE_DIFFUSE_MAP', self.diffuseMap)
    self:_defineFlag('USE_DIFFUSE_MAP_SAMPLER0', self.diffuseMap == 'sampler0')
    self:_defineFlag('USE_NORMAL_MAP', self.normalMap)
    self:_defineFlag('USE_VERTEX_COLORS', self.useVertexColors)
    self.program:compileImmediate()
end

function PhongMaterial:onFrameStart(scene)
    -- material uniforms
    self.program:uniform3fv('diffuse', self.diffuse)
    if self.diffuseMap and self.diffuseMap ~= 'sampler0' then
        local map = self.diffuseMap --[[@as RageTexture]]
        self.program:uniformTexture('diffuseMap', map)
        self.program:uniform2f('textureSize', map:GetTextureWidth(), map:GetTextureHeight())
        self.program:uniform2f('imageSize', map:GetImageWidth(), map:GetImageWidth())
    end
    self.program:uniform3fv('specular', self.specular)
    self.program:uniform3fv('emissive', self.emissive)
    self.program:uniform1f('shininess', self.shininess)
    if self.normalMap then
        self.program:uniformTexture('normalMap', self.normalMap)
        self.program:uniform2f('textureSize', self.normalMap:GetTextureWidth(), self.normalMap:GetTextureHeight())
        self.program:uniform2f('imageSize', self.normalMap:GetImageWidth(), self.normalMap:GetImageWidth())
    end

    -- scene uniforms
    self.program:uniform3fv('cameraPos', scene.camera.position)
    self.program:uniform3fv('lightPos', scene.lightPos)
    self.program:uniformMatrix4fv('tdViewMatrix', scene.camera.viewMatrix)
    self.program:uniformMatrix4fv('tdProjMatrix', scene.camera.projMatrix)
    self.program:uniform1i('doShadows', scene.doShadows and 1 or 0)
    if scene.doShadows then
        local sh = scene.shadowMap
        self.program:uniformTexture('shadowMap', sh)
        self.program:uniform2f('shadowMapTextureSize',
            sh:GetTextureWidth(), sh:GetTextureHeight()
        )
        self.program:uniform2f('shadowMapImageSize',
            sh:GetImageWidth(), sh:GetImageHeight()
        )
        self.program:uniformMatrix4fv('lightViewMatrix', scene.lightCamera.viewMatrix)
        self.program:uniformMatrix4fv('lightProjMatrix', scene.lightCamera.projMatrix)
        self.program:uniform1f('lightNearDist', scene.lightCamera.nearDist)
        self.program:uniform1f('lightFarDist', scene.lightCamera.farDist)
    end
    self.program:uniform1f('asdf', 1)
end

return PhongMaterial