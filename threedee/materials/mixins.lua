---@diagnostic disable: undefined-field
local Vec3 = require 'threedee.math.Vec3'

---@class MaterialMixin
---@field compile? fun(self: Material, scene: Scene)
---@field onFrameStart? fun(self: Material, scene: Scene)
---@field onBeforeDraw? fun(self: Material, act: ActorWithMaterial | NoteFieldProxy)

---@type {[string]: MaterialMixin}
local mixins = {
    ---Handles camera view/projection transforms, as well as the `cameraPos` uniform.
    ---Almost every material should probably have this.
    ---
    ---Associated snippets: `<position_*>`, optionally `<posvaryings_*>`
    CameraMixin = {
        onFrameStart = function(self, scene)
            self.shader:uniform3fv('cameraPos', scene.camera.position)
            self.shader:uniformMatrix4fv('tdViewMatrix', scene.camera:getViewMatrix())
            self.shader:uniformMatrix4fv('tdProjMatrix', scene.camera.projMatrix)
        end
    },

    ---Handles base color, color maps, and vertex colors.
    ---
    ---Required fields: `color: Vec3`, `colorMap?: RageTexture|'sampler0'`, `useVertexColors: boolean`
    ---
    ---Associated snippets: `<color_*>`
    ColorMixin = {
        compile = function(self)
            self:_defineFlag('USE_DIFFUSE_MAP', self.colorMap)
            self:_defineFlag('USE_DIFFUSE_MAP_SAMPLER0', self.colorMap == 'sampler0')
            self:_defineFlag('USE_VERTEX_COLORS', self.useVertexColors)
        end,

        onFrameStart = function(self)
            local sha = self.shader
            sha:uniform3fv('color', self.color)
            if self.colorMap and self.colorMap ~= 'sampler0' then
                local map = self.colorMap --[[@as RageTexture]]
                sha:uniformTexture('diffuseMap', map)
            end
        end
    },

    ---Handles normal maps.
    ---
    ---Required fields: `normalMap?: RageTexture`
    ---
    ---Associated snippets: `<normal_*>`
    NormalMapMixin = {
        compile = function(self)
            self:_defineFlag('USE_NORMAL_MAP', self.normalMap)
        end,

        onFrameStart = function(self)
            if self.normalMap then
                self.shader:uniformTexture('normalMap', self.normalMap)
            end
        end
    },

    ---Handles lights and shadows.
    ---
    ---Associated snippets: `<lights_*>`
    LightsMixin = {
        compile = function(self, scene)
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
}

return mixins