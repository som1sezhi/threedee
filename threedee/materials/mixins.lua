local Vec3 = require 'threedee.math.Vec3'
local cfs = require 'threedee.materials.changeFuncs'

---@class MaterialMixin
---@field init? fun(self: Material)
---@field setDefines? fun(self: Material, scene: Scene)
---@field onBeforeFirstDraw? fun(self: Material, scene: Scene)
---@field onFrameStart? fun(self: Material, scene: Scene)
---@field onBeforeDraw? fun(self: Material, act: ActorWithMaterial | NoteFieldProxy)
---@field changeFuncs? {[string]: ChangeFunc}
---@field eventHandlers? {[string]: EventHandler}

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
        self:dispatchEvent('cameraReplaced', { camera = scene.camera })
    end,

    eventHandlers = {
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
---@field transparent boolean
---@field opacity number
---@field alphaTest number
---@field alphaHash boolean

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
---@field color Vec3
---@field colorMap RageTexture|'sampler0'|false
---@field useVertexColors boolean

---Handles base color, color maps, and vertex colors.
---
---Defined fields: `color: Vec3`, `colorMap: RageTexture|'sampler0'|false`, `useVertexColors: boolean`
---
---Associated snippets: `<color_*>`
mixins.ColorMixin = {
    init = function(self)
        ---@cast self WithColor
        self.color = self.color or Vec3:new(1, 1, 1)
        self.colorMap = self.colorMap or false
        self.useVertexColors = self.useVertexColors or false
    end,

    setDefines = function(self)
        ---@cast self WithColor
        self:_defineFlag('USE_COLOR_MAP', self.colorMap)
        self:_defineFlag('USE_COLOR_MAP_SAMPLER0', self.colorMap == 'sampler0')
        self:_defineFlag('USE_VERTEX_COLORS', self.useVertexColors)
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
---@field alphaMap RageTexture|'sampler0'|false
---@field useVertexColorAlpha boolean

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
---@field normalMap RageTexture|false

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
    end,

    onBeforeFirstDraw = function(self, scene)
        local ambientLight = Vec3:new(0, 0, 0)
        for _, light in ipairs(scene.lights.ambientLights) do
            ambientLight:add(light.color:clone():scale(light.intensity))
        end
        self:dispatchEvent('ambientLight', { value = ambientLight })

        for _, light in ipairs(scene.lights.pointLights) do
            local idx = light.index
            local col = light.color:clone():scale(light.intensity)
            self:dispatchEvent('pointLightColor', { index = idx, value = col })
            self:dispatchEvent('pointLightPosition', { index = idx, value = light.position })
            self.shader:uniform1i(
                'pointLights[' .. idx .. '].castShadows',
                light.castShadows and 1 or 0
            )
            -- TODO remove this uniform
            self.shader:uniform1f(
                'pointLights[' .. idx .. '].intensity', 1
            )
        end

        local shadowMap = nil
        for _, shadow in ipairs(scene.lights.pointLightShadows) do
            local idx = shadow.index
            local camera = shadow.camera
            self:dispatchEvent(
                'pointLightShadowMatrix',
                { index = idx, value = camera.projMatrix * camera.viewMatrix }
            )
            self:dispatchEvent(
                'pointLightShadowNearDist',
                { index = idx, value = camera.nearDist }
            )
            self:dispatchEvent(
                'pointLightShadowFarDist',
                { index = idx, value = camera.farDist }
            )
            shadowMap = shadow.shadowMapAft:GetTexture()
            self.shader:uniformTexture('pointLightShadowMaps[' .. idx .. ']', shadowMap)
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

    onFrameStart = function(self, scene)
        self.shader:uniform1i('doShadows', scene.doShadows and 1 or 0)
    end,

    eventHandlers = {
        ambientLight = function(self, args)
            self.shader:uniform3fv('ambientLight', args.value)
        end,
        pointLightColor = function(self, args)
            local uname = 'pointLights[' .. args.index .. '].color'
            self.shader:uniform3fv(uname, args.value)
        end,
        pointLightPosition = function(self, args)
            local uname = 'pointLights[' .. args.index .. '].position'
            self.shader:uniform3fv(uname, args.value)
        end,
        pointLightShadowMatrix = function(self, args)
            local uname = 'pointLightMatrices[' .. args.index .. ']'
            self.shader:uniformMatrix4fv(uname, args.value)
        end,
        pointLightShadowNearDist = function(self, args)
            local uname = 'pointLightShadows[' .. args.index .. '].nearDist'
            self.shader:uniform1f(uname, args.value)
        end,
        pointLightShadowFarDist = function(self, args)
            local uname = 'pointLightShadows[' .. args.index .. '].farDist'
            self.shader:uniform1f(uname, args.value)
        end,
    }
}

---------------------------------------------------------------------

return mixins
