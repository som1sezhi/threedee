local class = require "threedee.class"

---@class Material
---@field shader RageShaderProgram
local Material = class('Material')

---@generic M : Material
---@param self M
---@param shaderOrActor RageShaderProgram | Actor
---@return M
function Material.new(self, shaderOrActor)
    -- actors have a GetShader method, RageShaderPrograms don't
    local shader
    if shaderOrActor.GetShader then
        local s = shaderOrActor:GetShader()
        if s == nil then
            error(
                'actor ' .. tostring(shaderOrActor) ..
                ' (' .. shaderOrActor:GetName() ..
                ') does not have a shader program'
            )
        end
        shader = s
    else
        shader = shaderOrActor
    end
    return setmetatable({ shader = shader }, self)
end

---Compiles the shader, setting the #defines according to the
---material and scene properties.
---Does not set any uniforms yet.
---@param scene Scene
function Material:compile(scene)
end

---Called at the beginning of each frame.
---@param scene Scene
function Material:onFrameStart(scene)
end

---Called before drawing an actor with this material.
---@param act ActorWithMaterial | NoteFieldProxy
function Material:onBeforeDraw(act)
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