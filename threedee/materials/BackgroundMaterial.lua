local Material = require 'threedee.materials.Material'
local sources = require 'threedee.glsl.shaders.backgroundmaterial'
local mixins  = require 'threedee.materials.mixins'
local materialClass = require 'threedee.materials.materialClass'
local Mat4 = require 'threedee.math.Mat4'
local Mat3 = require 'threedee.math.Mat3'
local Vec3 = require 'threedee.math.Vec3'
local cfs = require 'threedee.materials.changeFuncs'

---@class BackgroundMaterial: Material, WithCamera
---@field color Vec3
---@field colorMap RageTexture|false
---@field envMap EnvMap|false
---@field envMapRotation Mat3
---@field intensity number
local BackgroundMaterial = materialClass('BackgroundMaterial', Material, {
    mixins.CameraMixin
})

---@class (partial) BackgroundMaterial.P: BackgroundMaterial

BackgroundMaterial.vertSource = sources.vert
BackgroundMaterial.fragSource = sources.frag

---@type fun(self: BackgroundMaterial, initProps?: BackgroundMaterial.P): BackgroundMaterial
function BackgroundMaterial:new(initProps)
    local o = Material.new(self, initProps)
    o.color = o.color or Vec3:new(0, 0, 0)
    o.colorMap = o.colorMap or false
    o.envMap = o.envMap or false
    o.envMapRotation = o.envMapRotation or Mat3:new()
    o.intensity = o.intensity or 1
    return o
end

function BackgroundMaterial:setDefines(scene)
    Material.setDefines(self, scene)
    self:_defineFlag('USE_COLOR_MAP', self.colorMap)
    self:_defineFlag('USE_ENV_MAP', self.envMap)
    if self.envMap then
        self.shader:define('ENV_MAP_MAPPING_'..string.upper(self.envMap.mapping))
        self.shader:define('ENV_MAP_FORMAT_'..string.upper(self.envMap.colorFormat))
    end
end

function BackgroundMaterial:onBeforeFirstDraw(scene)
    Material.onBeforeFirstDraw(self, scene)
    if self.colorMap then
        self.shader:uniform2f('displayResolution', dw, dh)
    end
end

---@type fun(self: BackgroundMaterial, initProps?: BackgroundMaterial.P)
BackgroundMaterial.update = Material.update

BackgroundMaterial.changeFuncs['color'] = cfs.vec3ChangeFunc('color')
BackgroundMaterial.changeFuncs['colorMap'] = function(self, newVal)
    ---@cast self BackgroundMaterial
    newVal = newVal or self.colorMap
    if newVal then
        ---@cast newVal RageTexture
        self.shader:uniformTexture('colorMap', newVal)
        self.shader:uniform2f('colorMapTextureSize', newVal:GetTextureWidth(), newVal:GetTextureHeight())
        self.shader:uniform2f('colorMapImageSize', newVal:GetImageWidth(), newVal:GetImageHeight())
    end
end
BackgroundMaterial.changeFuncs['envMap'] = function(self, newVal)
    ---@cast self BackgroundMaterial
    newVal = newVal or self.envMap
    if newVal then
        ---@cast newVal EnvMap
        -- only support changing the texture, not its associated attributes
        self.shader:uniformTexture('envMap', newVal.texture)
    end
end
BackgroundMaterial.changeFuncs['envMapRotation'] = cfs.mat3ChangeFunc('envMapRotation')
BackgroundMaterial.changeFuncs['intensity'] = cfs.floatChangeFunc('intensity')

-- override camera event handlers to only send the rotation part of the view matrix,
-- so that the background object follows the camera
local tempMat4 = Mat4:new()
local tempMat3 = Mat3:new()
BackgroundMaterial.eventHandlers['viewMatrix'] = function(self, args)
    local rotationOnly = tempMat4:setUpperMat3(tempMat3:setFromMat4(args.value))
    self.shader:uniformMatrix4fv('tdViewMatrix', rotationOnly)
end
BackgroundMaterial.eventHandlers['cameraReplaced'] = function(self, args)
    local rotationOnly = tempMat4:setUpperMat3(tempMat3:setFromMat4(args.camera.viewMatrix))
    self.shader:uniform3fv('cameraPos', args.camera.position)
    self.shader:uniformMatrix4fv('tdViewMatrix', rotationOnly)
    self.shader:uniformMatrix4fv('tdProjMatrix', args.camera.projMatrix)
end

return BackgroundMaterial