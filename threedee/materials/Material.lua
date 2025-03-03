local class = require 'threedee.class'
local actors = require 'threedee._actors'

---@alias EventHandler fun(self: Material, args: table)
---@alias ChangeFunc fun(self: Material, newVal?: any)

---@class Material
---@field shader RageShaderProgram
---@field vertSource? string
---@field fragSource? string
---@field mixins MaterialMixin[]
---@field changeFuncs {[string]: ChangeFunc}
---@field eventHandlers {[string]: EventHandler}
---@field useCamera? boolean
---@field useLights? boolean
local Material = class('Material')

Material.mixins = {}
Material.eventHandlers = {}

---@generic M : Material
---@param self M
---@param initProps M?
---@return M
function Material.new(self, initProps)
    initProps = initProps or {}
    if initProps.shader == nil then
        local sh = actors.getMaterialActor():GetShader()
        if sh == nil then
            error('a material actor does not have a shader attached')
        end
        ---@diagnostic disable-next-line: inject-field
        initProps.shader = sh
    end
    local o = setmetatable(initProps, self)
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
    if self.vertSource and self.fragSource then
        self.shader:compile(self.vertSource, self.fragSource)
    end
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

---Set properties of the material, and updates the corresponding shader uniforms.
---@param props Material
function Material:update(props)
    for k, v in pairs(props) do
        self[k] = v
        local changeFunc = self.changeFuncs[k]
        if changeFunc then
            changeFunc(self)
        end
    end
end

local function allPairsIter(state, prevKey)
    local key, val = next(state.currTable, prevKey)
    -- exits if key has not been found yet
    -- (note that this also exits if key is nil, since nil can never be an index)
    while state.foundKeys[key] do
        key, val = next(state.currTable, key)
    end
    if key ~= nil then
        state.foundKeys[key] = true
        return key, val
    else
        while key == nil do
            state.currTable = getmetatable(state.currTable).__index
            if type(state.currTable) ~= 'table' then
                return -- end iteration (no more __index tables to iterate through)
            end
            key, val = next(state.currTable, nil)
            while state.foundKeys[key] do
                key, val = next(state.currTable, key)
            end
        end
        state.foundKeys[key] = true
        return key, val
    end
end

local function allPairs(tab)
    local state = {
        currTable = tab,
        foundKeys = {}
    }
    return allPairsIter, state, nil
end

---Called just before drawing the scene for the first time.
---This function ensures that all the shader uniforms are initialized before drawing.
---@param scene Scene
function Material:onBeforeFirstDraw(scene)
    for _, changeFunc in allPairs(self.changeFuncs) do
        changeFunc(self)
    end
    for _, mixin in ipairs(self.mixins) do
        if mixin.onBeforeFirstDraw then
            mixin.onBeforeFirstDraw(self, scene)
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
---@param act ActorWithMaterial
function Material:onBeforeDraw(act)
    for _, mixin in ipairs(self.mixins) do
        if mixin.onBeforeDraw then
            mixin.onBeforeDraw(self, act)
        end
    end
end

---Dispatch an event to the material.
---@param event string
---@param args table
function Material:dispatchEvent(event, args)
    local handler = self.eventHandlers[event]
    if handler then
        handler(self, args)
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