local Vec3 = require 'threedee.math.Vec3'
local Mat3 = require 'threedee.math.Mat3'
local cfs = require 'threedee.materials.changeFuncs'

local typeToUniformFunc = {
    float = 'uniform1f',
    vec2 = 'uniform2fv',
    vec3 = 'uniform3fv',
    vec4 = 'uniform4fv',
    mat4 = 'uniformMatrix4fv',
}

---@class MaterialMixin
---@field init? fun(self: Material)
---@field setDefines? fun(self: Material, scene: Scene)
---@field onBeforeFirstDraw? fun(self: Material, scene: Scene)
---@field onFrameStart? fun(self: Material, scene: Scene)
---@field onBeforeDraw? fun(self: Material, act: ActorWithMaterial)
---@field changeFuncs? {[string]: ChangeFunc}
---@field listeners? {[string]: MaterialListener}

---@type {[string]: MaterialMixin}
local mixins = {}

---------------------------------------------------------------------

---@class WithCamera: Material
---@field useCamera true

---Handles camera view/projection transforms, as well as the `cameraPos` uniform.
---Almost every material should probably have this.
---
---Defined fields: `usesCamera: true`
---
---Associated snippets: `<position_*>`, optionally `<posvaryings_*>`
mixins.CameraMixin = {
    init = function(self)
        ---@cast self WithCamera
        self.useCamera = true
    end,

    onBeforeFirstDraw = function(self, scene)
        self.listeners['cameraReplaced'](self, { camera = scene.camera })
    end,

    listeners = {
        cameraPos = function(self, args)
            self.shader:uniform3fv('cameraPos', args.value)
        end,
        viewMatrix = function(self, args)
            self.shader:uniformMatrix4fv('tdViewMatrix', args.value)
        end,
        projMatrix = function(self, args)
            self.shader:uniformMatrix4fv('tdProjMatrix', args.value)
        end,
        cameraReplaced = function(self, args)
            self.shader:uniform3fv('cameraPos', args.camera.position)
            self.shader:uniformMatrix4fv('tdViewMatrix', args.camera.viewMatrix)
            self.shader:uniformMatrix4fv('tdProjMatrix', args.camera.projMatrix)
        end
    }
}

---------------------------------------------------------------------

---@class WithAlpha: Material
---@field transparent boolean (X) Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded. Default: `false`
---@field opacity number (U) The base alpha. Default: `1` (fully opaque)
---@field alphaTest number (U) Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false. Default: `0.001`
---@field alphaHash boolean (X) Enable [hashed alpha testing](https://casual-effects.com/research/Wyman2017Hashed/index.html). If alpha is lower than a random threshold, the pixel is discarded. This allows for the appearance of gradations of transparency even if `.transparent` is false, and also allows for overlapping transparent geometry looking correct without having to sort them by distance, though the result can end up very noisy. Default: `false`

---Handles transparency/opacity, alpha testing, and alpha hashing.
---
---Defined fields: `transparent: boolean`, `opacity: number`, `alphaTest: number`, `alphaHash: boolean`
---
---Associated snippets: `<alpha_*>`, `<alphadiscard_*>`
mixins.AlphaMixin = {
    init = function(self)
        ---@cast self WithAlpha
        self.transparent = self.transparent or false
        self.opacity = self.opacity or 1
        self.alphaTest = self.alphaTest or 0.001
        self.alphaHash = self.alphaHash or false
    end,

    setDefines = function(self)
        ---@cast self WithAlpha
        self:_defineFlag('TRANSPARENT', self.transparent)
        self:_defineFlag('USE_ALPHA_HASH', self.alphaHash)
    end,

    changeFuncs = {
        opacity = cfs.floatChangeFunc('opacity'),
        alphaTest = cfs.floatChangeFunc('alphaTest'),
    }
}

---------------------------------------------------------------------

---@class WithColor: Material
---@field color Vec3 (U) Base color. Default: `(1, 1, 1)` (white)
---@field colorMap RageTexture|'sampler0'|false (C) Base color texture. An alpha channel may be included. If set to `'sampler0'`, use the actor's default texture. Default: `false`
---@field useVertexColors boolean (X) Whether to use the actor's vertex colors to color the material. Among other things, this allows you to color actors individually using `:diffuse()`. Default: `false`
---@field vertexColorInterpolation 'srgb'|'linear' (X) If using vertex colors, this defines whether to interpolate vertex colors in linear RGB or sRGB space. Linear RGB is more "correct" and can look better in certain cases, while sRGB gives closer results to what you might get using regular NotITG methods like `:diffusetopedge()` and such. Note that the vertex color values themselves are always specified in sRGB space. Default: `'linear'` 

---Handles base color, color maps, and vertex colors.
---
---Defined fields: `color: Vec3`, `colorMap: RageTexture|'sampler0'|false`, `useVertexColors: boolean`, `vertexColorInterpolation: 'srgb'|'linear'`
---
---Associated snippets: `<color_*>`
mixins.ColorMixin = {
    init = function(self)
        ---@cast self WithColor
        self.color = self.color or Vec3:new(1, 1, 1)
        self.colorMap = self.colorMap or false
        self.useVertexColors = self.useVertexColors or false
        self.vertexColorInterpolation = self.vertexColorInterpolation or 'linear'
    end,

    setDefines = function(self)
        ---@cast self WithColor
        self:_defineFlag('USE_COLOR_MAP', self.colorMap)
        self:_defineFlag('USE_COLOR_MAP_SAMPLER0', self.colorMap == 'sampler0')
        self:_defineFlag('USE_VERTEX_COLORS', self.useVertexColors)
        self:_defineFlag(
            'VERTEX_COLORS_INTERPOLATE_LINEAR',
            self.vertexColorInterpolation == 'linear'
        )
    end,

    changeFuncs = {
        color = cfs.vec3ChangeFunc('color'),
        colorMap = function(self, newVal)
            ---@cast self WithColor
            newVal = newVal or self.colorMap
            if newVal and newVal ~= 'sampler0' then
                self.shader:uniformTexture('colorMap', newVal)
            end
        end,
    }
}

---------------------------------------------------------------------

---@class WithAlphaMap: Material
---@field alphaMap RageTexture|'sampler0'|false (C) The alpha channel of this texture is used to modulate the material's alpha. If set to `'sampler0'`, use the actor's default texture. Default: `false`
---@field useVertexColorAlpha boolean (X) Whether to use the actor's vertex color alpha to modulate the alpha of the material. Default: `false`

---Handles alpha maps. This is for materials that do not have color maps otherwise.
---USE_VERTEX_COLORS should be defined at the top of shaders that support this mixin.
---
---Defined fields: `alphaMap: RageTexture|'sampler0'|false`, `useVertexColorAlpha: boolean`
---
---Associated snippets: `<alphamap_*>`
mixins.AlphaMapMixin = {
    init = function(self)
        ---@cast self WithAlphaMap
        self.alphaMap = self.alphaMap or false
        self.useVertexColorAlpha = self.useVertexColorAlpha or false
    end,

    -- we use uniforms instead of define flags to switch between the different behaviors,
    -- since for the purposes of shadowmaps, i'd like to be able to change properties
    -- on the depth material without switching shader programs

    changeFuncs = {
        useVertexColorAlpha = cfs.boolChangeFunc('useVertexColorAlpha'),
        alphaMap = function(self, newVal)
            ---@cast self WithAlphaMap
            local alphaMap = newVal or self.alphaMap
            local sha = self.shader
            sha:uniform1i('useAlphaMap', alphaMap and 1 or 0)
            if self.alphaMap then
                sha:uniform1i('useSampler0AlphaMap', alphaMap == 'sampler0' and 1 or 0)
                if self.alphaMap ~= 'sampler0' then
                    sha:uniformTexture('alphaMap', alphaMap)
                end
            end
        end,
    }
}

---------------------------------------------------------------------

---@class WithNormalMap: Material
---@field normalMap RageTexture|false (C) The normal map. Default: `false`

---Handles normal maps.
---
---Defined fields: `normalMap: RageTexture|false`
---
---Associated snippets: `<normal_*>`
mixins.NormalMapMixin = {
    init = function(self)
        ---@cast self WithNormalMap
        self.normalMap = self.normalMap or false
    end,

    setDefines = function(self)
        ---@cast self WithNormalMap
        self:_defineFlag('USE_NORMAL_MAP', self.normalMap)
    end,

    changeFuncs = {
        normalMap = cfs.optTextureChangeFunc('normalMap')
    }
}

---------------------------------------------------------------------

---@class WithEnvMap: Material
---@field envMap EnvMap|false (C) The environment map. Default: `false`
---@field envMapType 'reflection'|'refraction' (X) Whether to use `.envMap` as a reflection or refraction map. Default: `'reflection'`
---@field envMapStrength number (U) How much the environment map affects the color of the material. Default: `1` (full strength)
---@field envMapCombine 'multiply'|'add'|'mix' (X) The math operation used to blend the environment map with the material. Default: `'multiply'`
---@field envMapRotation Mat3 (U) The rotation of the environment map. Default: identity matrix
---@field refractionRatio number (U) The index of refraction (IOR) of air divided by the IOR of the material. Only has an effect if `.envMapType = 'refraction'`. Default: `0.98`

---Handles environment maps.
---
---Defined fields: `envMap: EnvMap|false`, `envMapType: 'reflection'|'refraction'`, `envMapStrength: number`, `envMapCombine: 'multiply'|'add'|'mix'`, `envMapRotation: Mat3`, `refractionRatio: number`
---
---Associated snippets: `<envmap_*>`
mixins.EnvMapMixin = {
    init = function(self)
        ---@cast self WithEnvMap
        self.envMap = self.envMap or false
        self.envMapType = self.envMapType or 'reflection'
        self.envMapStrength = self.envMapStrength or 1
        self.envMapCombine = self.envMapCombine or 'multiply'
        self.envMapRotation = self.envMapRotation or Mat3:new()
        self.refractionRatio = self.refractionRatio or 0.98
    end,

    setDefines = function(self)
        ---@cast self WithEnvMap
        self:_defineFlag('USE_ENV_MAP', self.envMap)
        if self.envMap then
            self.shader:define('ENV_MAP_MAPPING_'..string.upper(self.envMap.mapping))
            self.shader:define('ENV_MAP_FORMAT_'..string.upper(self.envMap.colorFormat))
        end
        self.shader:define('ENV_MAP_TYPE_'..string.upper(self.envMapType))
        self.shader:define('ENV_MAP_COMBINE_'..string.upper(self.envMapCombine))
    end,

    changeFuncs = {
        envMap = function(self, newVal)
            ---@cast self WithEnvMap
            local envMap = newVal or self.envMap
            -- only support changing the texture, not its associated attributes
            if envMap then
                self.shader:uniformTexture('envMap', envMap.texture)
            end
        end,
        envMapStrength = cfs.floatChangeFunc('envMapStrength'),
        envMapRotation = cfs.mat3ChangeFunc('envMapRotation'),
        refractionRatio = cfs.floatChangeFunc('refractionRatio')
    }
}

---------------------------------------------------------------------

---@class WithDithering: Material
---@field dithering boolean (X) Whether to perform dithering. This can reduce the appearance of banding artifacts at the cost of introducing some noise. Default: `false`

---Handles dithering.
---
---Defined fields: `dithering: boolean`
---
---Associated snippets: `<dithering_*>`
mixins.DitheringMixin = {
    init = function(self)
        ---@cast self WithDithering
        self.dithering = self.dithering or false
    end,

    setDefines = function(self)
        ---@cast self WithDithering
        self:_defineFlag('DITHERING', self.dithering)
    end
}

---------------------------------------------------------------------

local function lightUniformListener(uniformArrayName)
    local template = uniformArrayName .. '[%d].%s'
    return function(self, args)
        local uname = string.format(template, args[1], args[3])
        local funcName = typeToUniformFunc[args[2]]
        self.shader[funcName](self.shader, uname, args[4])
    end
end

---@class WithLights: Material
---@field useLights true

---Handles lights and shadows.
---
---Defined fields: `useLights: true`
---
---Associated snippets: `<lights_*>`
mixins.LightsMixin = {
    init = function(self)
        ---@cast self WithLights
        self.useLights = true
    end,

    setDefines = function(self, scene)
        self.shader:define('USE_AMBIENT_LIGHT', #scene.lights.ambientLights > 0)
        self.shader:define('NUM_POINT_LIGHTS', tostring(#scene.lights.pointLights))
        self.shader:define('NUM_POINT_LIGHT_SHADOWS', tostring(#scene.lights.pointLightShadows))
        self.shader:define('NUM_DIR_LIGHTS', tostring(#scene.lights.dirLights))
        self.shader:define('NUM_DIR_LIGHT_SHADOWS', tostring(#scene.lights.dirLightShadows))
        self.shader:define('NUM_SPOT_LIGHTS', tostring(#scene.lights.spotLights))
        self.shader:define('NUM_SPOT_LIGHT_SHADOWS', tostring(#scene.lights.spotLightShadows))

        self.shader:define('NUM_SPOT_LIGHT_COLOR_MAPS', tostring(scene.lights.numSpotLightColorMaps))
        self.shader:define('NUM_SPOT_LIGHT_MATRICES', tostring(scene.lights.numSpotLightMatrices))

        self.shader:define('SHADOWMAP_FILTER_' .. string.upper(scene.shadowMapFilter))
    end,

    onBeforeFirstDraw = function(self, scene)
        -- a lot of this doesn't feel super elegant...

        local function dispatchToSelf(topic, args)
            self.listeners[topic](self, args)
        end

        local ambientLight = Vec3:new(0, 0, 0)
        for _, light in ipairs(scene.lights.ambientLights) do
            ambientLight:add(light.color:clone():scale(light.intensity))
        end
        dispatchToSelf('ambientLight', { value = ambientLight })

        for _, light in ipairs(scene.lights.pointLights) do
            local idx = light.index
            local col = light.color:clone():scale(light.intensity)
            dispatchToSelf('pointLightProp', { idx, 'vec3', 'color', col })
            dispatchToSelf('pointLightProp', { idx, 'vec3', 'position', light.position })
            dispatchToSelf('pointLightProp', { idx, 'float', 'linearAttenuation', light.linearAttenuation })
            dispatchToSelf('pointLightProp', { idx, 'float', 'quadraticAttenuation', light.quadraticAttenuation })
        end
        for _, light in ipairs(scene.lights.dirLights) do
            local idx = light.index
            local col = light.color:clone():scale(light.intensity)
            local facing = Vec3:new(0, 0, -1):applyQuat(light.rotation)
            dispatchToSelf('dirLightProp', { idx, 'vec3', 'color', col })
            dispatchToSelf('dirLightProp', { idx, 'vec3', 'direction', facing })
        end
        for _, light in ipairs(scene.lights.spotLights) do
            local idx = light.index
            local col = light.color:clone():scale(light.intensity)
            local facing = Vec3:new(0, 0, -1):applyQuat(light.rotation)
            local cosAngle = math.cos(light.angle)
            local cosInnerAngle = math.cos(light.angle * (1 - light.penumbra))
            dispatchToSelf('spotLightProp', { idx, 'vec3', 'color', col })
            dispatchToSelf('spotLightProp', { idx, 'vec3', 'position', light.position })
            dispatchToSelf('spotLightProp', { idx, 'vec3', 'direction', facing })
            dispatchToSelf('spotLightProp', { idx, 'float', 'cosAngle', cosAngle })
            dispatchToSelf('spotLightProp', { idx, 'float', 'cosInnerAngle', cosInnerAngle })
            dispatchToSelf('spotLightProp', { idx, 'float', 'linearAttenuation', light.linearAttenuation })
            dispatchToSelf('spotLightProp', { idx, 'float', 'quadraticAttenuation', light.quadraticAttenuation })
            if light.colorMap then
                dispatchToSelf('spotLightColorMap', { index = light.colorMapIndex, value = light.colorMap })
            end
            if light.colorMap or light.castShadows then
                dispatchToSelf('spotLightShadowMatrix',
                    { index = idx, value = light.shadow.camera.projMatrix * light.shadow.camera.viewMatrix }
                )
            end
        end

        local shadowMap = nil
        for i, shadow in ipairs(scene.lights.pointLightShadows) do
            local idx = i - 1
            local camera = shadow.camera
            dispatchToSelf('pointLightShadowMatrix',
                { index = idx, value = camera.projMatrix * camera.viewMatrix }
            )
            dispatchToSelf('pointLightShadowProp', { idx, 'float', 'nearDist', camera.nearDist })
            dispatchToSelf('pointLightShadowProp', { idx, 'float', 'farDist', camera.farDist })
            dispatchToSelf('pointLightShadowProp', { idx, 'float', 'bias', shadow.bias })
            shadowMap = shadow.shadowMapAft:GetTexture()
            self.shader:uniformTexture('pointLightShadowMaps[' .. idx .. ']', shadowMap)
        end
        for i, shadow in ipairs(scene.lights.dirLightShadows) do
            local idx = i - 1
            local camera = shadow.camera
            dispatchToSelf('dirLightShadowMatrix',
                { index = idx, value = camera.projMatrix * camera.viewMatrix }
            )
            dispatchToSelf('dirLightShadowProp', { idx, 'float', 'nearDist', camera.nearDist })
            dispatchToSelf('dirLightShadowProp', { idx, 'float', 'farDist', camera.farDist })
            dispatchToSelf('dirLightShadowProp', { idx, 'float', 'bias', shadow.bias })
            shadowMap = shadow.shadowMapAft:GetTexture()
            self.shader:uniformTexture('dirLightShadowMaps[' .. idx .. ']', shadowMap)
        end
        for i, shadow in ipairs(scene.lights.spotLightShadows) do
            local idx = i - 1
            local camera = shadow.camera
            dispatchToSelf('spotLightShadowProp', { idx, 'float', 'nearDist', camera.nearDist })
            dispatchToSelf('spotLightShadowProp', { idx, 'float', 'farDist', camera.farDist })
            dispatchToSelf('spotLightShadowProp', { idx, 'float', 'bias', shadow.bias })
            shadowMap = shadow.shadowMapAft:GetTexture()
            self.shader:uniformTexture('spotLightShadowMaps[' .. idx .. ']', shadowMap)
        end

        if shadowMap ~= nil then
            self.shader:uniform2f('shadowMapTextureSize',
                shadowMap:GetTextureWidth(), shadowMap:GetTextureHeight()
            )
            self.shader:uniform2f('shadowMapImageSize',
                shadowMap:GetImageWidth(), shadowMap:GetImageHeight()
            )
        end
    end,

    onBeforeDraw = function (self, act)
        self.shader:uniform1i(
            'doShadows',
            (act.scene.doShadows and act.receiveShadows) and 1 or 0
        )
    end,

    listeners = {
        ambientLight = function(self, args)
            self.shader:uniform3fv('ambientLight', args.value)
        end,
        pointLightProp = lightUniformListener('pointLights'),
        pointLightShadowMatrix = function(self, args)
            local uname = 'pointLightMatrices[' .. args.index .. ']'
            self.shader:uniformMatrix4fv(uname, args.value)
        end,
        pointLightShadowProp = lightUniformListener('pointLightShadows'),
        dirLightProp = lightUniformListener('dirLights'),
        dirLightShadowMatrix = function(self, args)
            local uname = 'dirLightMatrices[' .. args.index .. ']'
            self.shader:uniformMatrix4fv(uname, args.value)
        end,
        dirLightShadowProp = lightUniformListener('dirLightShadows'),
        spotLightProp = lightUniformListener('spotLights'),
        spotLightColorMap = function(self, args)
            local uname = 'spotLightColorMaps[' .. args.index .. ']'
            self.shader:uniformTexture(uname, args.value)
        end,
        spotLightShadowMatrix = function(self, args)
            local uname = 'spotLightMatrices[' .. args.index .. ']'
            self.shader:uniformMatrix4fv(uname, args.value)
        end,
        spotLightShadowProp = lightUniformListener('spotLightShadows'),
    }
}

---------------------------------------------------------------------

return mixins
