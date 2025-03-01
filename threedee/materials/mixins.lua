local Vec3 = require 'threedee.math.Vec3'

---@param name string
---@return ChangeFunc
local function uniform1iChangeFunc(name)
    return function(self, newVal)
        newVal = newVal or self[name]
        self.shader:uniform1i(name, newVal and 1 or 0)
    end
end

---@param name string
---@return ChangeFunc
local function uniform1fChangeFunc(name)
    return function(self, newVal)
        newVal = newVal or self[name]
        self.shader:uniform1f(name, newVal)
    end
end

---@param name string
---@return ChangeFunc
local function uniform3fvChangeFunc(name)
    return function(self, newVal)
        newVal = newVal or self[name]
        self.shader:uniform3fv(name, newVal)
    end
end

---@param name string
---@return ChangeFunc
local function uniformTextureOptionalChangeFunc(name)
    return function(self, newVal)
        newVal = newVal or self[name]
        if newVal then
            self.shader:uniformTexture(name, newVal)
        end
    end
end

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

---Handles camera view/projection transforms, as well as the `cameraPos` uniform.
---Almost every material should probably have this.
---
---Associated snippets: `<position_*>`, optionally `<posvaryings_*>`
mixins.CameraMixin = {
    onFrameStart = function(self, scene)
        self.shader:uniform3fv('cameraPos', scene.camera.position)
        self.shader:uniformMatrix4fv('tdViewMatrix', scene.camera:getViewMatrix())
        self.shader:uniformMatrix4fv('tdProjMatrix', scene.camera.projMatrix)
    end
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
        opacity = uniform1fChangeFunc('opacity'),
        alphaTest = uniform1fChangeFunc('alphaTest'),
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
        color = uniform3fvChangeFunc('color'),
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
        useVertexColorAlpha = uniform1iChangeFunc('useVertexColorAlpha'),
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
        normalMap = uniformTextureOptionalChangeFunc('normalMap')
    }
}

---------------------------------------------------------------------

---Handles lights and shadows.
---
---Associated snippets: `<lights_*>`
mixins.LightsMixin = {
    setDefines = function(self, scene)
        self.shader:define('USE_AMBIENT_LIGHT', #scene.lights.ambientLights > 0)
        self.shader:define('NUM_POINT_LIGHTS', tostring(#scene.lights.pointLights))
        self.shader:define('NUM_POINT_LIGHT_SHADOWS', tostring(#scene.lights.pointLightShadows))
    end,

    onFrameStart = function(self, scene)
        local sha = self.shader
        -- AMBIENT LIGHTS ---------------------------------------
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
            local prefix = 'pointLights[' .. i .. '].'
            sha:uniform3fv(prefix .. 'color', light.color)
            sha:uniform1f(prefix .. 'intensity', light.intensity)
            sha:uniform3fv(prefix .. 'position', light.position)
            sha:uniform1i(prefix .. 'castShadows', light.castShadows and 1 or 0)
        end

        -- SHADOWS ---------------------------------------
        sha:uniform1i('doShadows', scene.doShadows and 1 or 0)
        if scene.doShadows then
            local shadowMap = nil

            for idx, shadow in ipairs(scene.lights.pointLightShadows) do
                local i = idx - 1
                shadowMap = shadow.shadowMapAft:GetTexture()
                sha:uniformMatrix4fv('pointLightMatrices[' .. i .. ']',
                    shadow.camera.projMatrix * shadow.camera.viewMatrix)
                sha:uniformTexture('pointLightShadowMaps[' .. i .. ']', shadowMap)
                sha:uniform1f('pointLightShadows[' .. i .. '].nearDist', shadow.camera.nearDist)
                sha:uniform1f('pointLightShadows[' .. i .. '].farDist', shadow.camera.farDist)
            end

            -- TODO: can probably factor out
            if shadowMap ~= nil then
                sha:uniform2f('shadowMapTextureSize',
                    shadowMap:GetTextureWidth(), shadowMap:GetTextureHeight()
                )
                sha:uniform2f('shadowMapImageSize',
                    shadowMap:GetImageWidth(), shadowMap:GetImageHeight()
                )
            end
        end
    end
}

---------------------------------------------------------------------

return mixins