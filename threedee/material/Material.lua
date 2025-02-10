local class = require "threedee.class"

---@class Material
---@field program RageShaderProgram
local Material = class('Material')

---@generic M : Material
---@param self M
---@param programOrActor RageShaderProgram | Actor
---@return M
function Material.new(self, programOrActor)
    -- actors have a GetShader method, RageShaderPrograms don't
    local program
    if programOrActor.GetShader then
        local p = programOrActor:GetShader()
        if p == nil then
            error(
                'actor ' .. tostring(programOrActor) ..
                ' (' .. programOrActor:GetName() ..
                ') does not have a shader program'
            )
        end
        program = p
    else
        program = programOrActor
    end
    return setmetatable({ program = program }, self)
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

---Called before drawing an object with this material.
---@param obj Object
function Material:onBeforeDraw(obj)
end

---@param key string
---@param condition any
function Material:_defineFlag(key, condition)
    if condition then
        self.program:define(key, 1)
    else
        self.program:clearDefine(key)
    end
end

return Material