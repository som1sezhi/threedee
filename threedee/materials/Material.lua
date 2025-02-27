local class = require 'threedee.class'
local actors = require 'threedee._actors'

---@class Material
---@field shader RageShaderProgram
---@field vertSource string
---@field fragSource string
---@field mixins MaterialMixin[]
local Material = class('Material')

Material.mixins = {}
Material.vertSource = ''
Material.fragSource = ''

---@generic M : Material
---@param self M
---@return M
function Material.new(self)
    -- actors have a GetShader method, RageShaderPrograms don't
    local shader = actors.getMaterialActor():GetShader()
    if shader == nil then
        error('a material actor does not have a shader attached')
    end
    local o = setmetatable({ shader = shader }, self)
    for _, mixin in ipairs(o.mixins) do
        if mixin.init then
            mixin.init(o)
        end
    end
    return o
end

---Compiles the shader, setting the #defines according to the
---material and scene properties.
---Does not set any uniforms yet.
---@param scene Scene
function Material:compile(scene)
    self.shader:compile(self.vertSource, self.fragSource)
    self:setDefines(scene)
    self.shader:compileImmediate()
end

---Sets the #defines according to the material and scene properties.
---@param scene Scene
function Material:setDefines(scene)
    for _, mixin in ipairs(self.mixins) do
        if mixin.setDefines then
            mixin.setDefines(self, scene)
        end
    end
end

---Called at the beginning of each frame.
---@param scene Scene
function Material:onFrameStart(scene)
    for _, mixin in ipairs(self.mixins) do
        if mixin.onFrameStart then
            mixin.onFrameStart(self, scene)
        end
    end
end

---Called before drawing an actor with this material.
---@param act ActorWithMaterial | NoteFieldProxy
function Material:onBeforeDraw(act)
    for _, mixin in ipairs(self.mixins) do
        if mixin.onBeforeDraw then
            mixin.onBeforeDraw(self, act)
        end
    end
end

---@param key string
---@param condition any
function Material:_defineFlag(key, condition)
    if condition then
        self.shader:define(key, nil)
    else
        self.shader:clearDefine(key)
    end
end

return Material