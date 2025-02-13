local class = require 'threedee.class'
local Vec3 = require 'threedee.math.Vec3'
local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.phongmaterial'

---@class PhongMaterial: Material
---@field diffuse Vec3 diffuse color
---@field diffuseMap? RageTexture|'sampler0'
---@field specular Vec3 specular color
---@field emissive Vec3 emissive/ambient color
---@field shininess number sharpness of highlight
---@field normalMap? RageTexture
---@field useVertexColors boolean whether to use vertex colors to modulate the base color
local PhongMaterial = class('PhongMaterial', Material)

function PhongMaterial:new(programOrActor)
    local o = Material.new(self, programOrActor)
    o.diffuse = Vec3:new(1, 1, 1)
    o.specular = Vec3:new(1, 1, 1)
    o.emissive = Vec3:new(0, 0, 0)
    o.shininess = 30
    o.useVertexColors = false
    return o
end

function PhongMaterial:compile(scene)
    self.program:compile(sources.vert, sources.frag)

    self.program:define('USE_AMBIENT_LIGHT', #scene.lights.ambientLights > 0)
    self.program:define('NUM_POINT_LIGHTS', tostring(#scene.lights.pointLights))
    self.program:define('NUM_POINT_LIGHT_SHADOWS', tostring(#scene.lights.pointLightShadows))

    self:_defineFlag('USE_DIFFUSE_MAP', self.diffuseMap)
    self:_defineFlag('USE_DIFFUSE_MAP_SAMPLER0', self.diffuseMap == 'sampler0')
    self:_defineFlag('USE_NORMAL_MAP', self.normalMap)
    self:_defineFlag('USE_VERTEX_COLORS', self.useVertexColors)

    self.program:compileImmediate()
end

function PhongMaterial:onFrameStart(scene)
    local sha = self.program
    -- material uniforms
    sha:uniform3fv('color', self.diffuse)
    if self.diffuseMap and self.diffuseMap ~= 'sampler0' then
        local map = self.diffuseMap --[[@as RageTexture]]
        sha:uniformTexture('diffuseMap', map)
        sha:uniform2f('textureSize', map:GetTextureWidth(), map:GetTextureHeight())
        sha:uniform2f('imageSize', map:GetImageWidth(), map:GetImageWidth())
    end
    sha:uniform3fv('specular', self.specular)
    sha:uniform3fv('emissive', self.emissive)
    sha:uniform1f('shininess', self.shininess)
    if self.normalMap then
        sha:uniformTexture('normalMap', self.normalMap)
        sha:uniform2f('textureSize', self.normalMap:GetTextureWidth(), self.normalMap:GetTextureHeight())
        sha:uniform2f('imageSize', self.normalMap:GetImageWidth(), self.normalMap:GetImageWidth())
    end

    -- scene uniforms
    sha:uniform3fv('cameraPos', scene.camera.position)
    sha:uniformMatrix4fv('tdViewMatrix', scene.camera.viewMatrix)
    sha:uniformMatrix4fv('tdProjMatrix', scene.camera.projMatrix)
    sha:uniform1i('doShadows', scene.doShadows and 1 or 0)

    -- light uniforms
    if #scene.lights.ambientLights > 0 then
        local ambientLight = Vec3:new(0, 0, 0)
        for _, light in ipairs(scene.lights.ambientLights) do
            ambientLight:add(light.color:clone():scale(light.intensity))
        end
        sha:uniform3fv('ambientLight', ambientLight)
    end
    -- POINT LIGHTS ---------------------------------------
    for idx, light in ipairs(scene.lights.pointLights) do
        local i = idx - 1
        local prefix = 'pointLights['..i..'].'
        sha:uniform3fv(prefix..'color', light.color)
        sha:uniform1f(prefix..'intensity', light.intensity)
        sha:uniform3fv(prefix..'position', light.position)
        sha:uniform1i(prefix..'castShadows', light.castShadows and 1 or 0)
    end
    if scene.doShadows then
        local shadowMap = nil
        for idx, shadow in ipairs(scene.lights.pointLightShadows) do
            local i = idx - 1
            shadowMap = shadow.shadowMapAft:GetTexture()
            sha:uniformMatrix4fv('pointLightMatrices['..i..']', shadow.camera.projMatrix * shadow.camera.viewMatrix)
            sha:uniformTexture('pointLightShadowMaps['..i..']', shadowMap)
            sha:uniform1f('pointLightShadows['..i..'].nearDist', shadow.camera.nearDist)
            sha:uniform1f('pointLightShadows['..i..'].farDist', shadow.camera.farDist)
        end
        if shadowMap ~= nil then
            self.program:uniform2f('shadowMapTextureSize',
                shadowMap:GetTextureWidth(), shadowMap:GetTextureHeight()
            )
            self.program:uniform2f('shadowMapImageSize',
                shadowMap:GetImageWidth(), shadowMap:GetImageHeight()
            )
        end
    end
end

return PhongMaterial