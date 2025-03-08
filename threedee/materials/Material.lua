local class = require 'threedee.class'
local actors = require 'threedee._actors'
local Updatable = require 'threedee.Updatable'

---@alias MaterialListener fun(self: Material, args: table)
---@alias ChangeFunc fun(self: Material, newVal?: any)

---@class Material: Updatable
---@field shader RageShaderProgram
---@field vertSource? string
---@field fragSource? string
---@field mixins MaterialMixin[]
---@field changeFuncs {[string]: ChangeFunc}
---@field listeners {[string]: MaterialListener}
---@field useCamera? boolean
---@field useLights? boolean
local Material = class('Material', Updatable)

---@class (partial) Material.P: Material

Material.mixins = {}
Material.listeners = {}

---@generic M: Material
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

---Add a new mixin to this material after creation.
---This should be called before assigning this material to any actor
---@param mixin MaterialMixin
function Material:addMixin(mixin)
    -- make copies of various tables just for this material so
    -- they don't pollute tables shared by other materials
    if rawget(self, 'mixins') == nil then
        -- make a copy just 
        local mixins = self.mixins
        self.mixins = {}
        for _, m in ipairs(mixins) do
            table.insert(self.mixins, m)
        end
    end
    if rawget(self, 'changeFuncs') == nil then
        self.changeFuncs = setmetatable({}, {__index = self.changeFuncs})
    end
    if rawget(self, 'listeners') == nil then
        self.listeners = setmetatable({}, {__index = self.listeners})
    end

    -- TODO: have materialClass use this method?    
    table.insert(self.mixins, mixin)
    -- add new changeFuncs
    if mixin.changeFuncs then
        for k, changeFunc in pairs(mixin.changeFuncs) do
            self.changeFuncs[k] = changeFunc
        end
    end
    -- add new listeners
    if mixin.listeners then
        for k, listeners in pairs(mixin.listeners) do
            self.listeners[k] = listeners
        end
    end
    -- ensure mixin attributes are initialized
    if mixin.init then
        mixin.init(self)
    end
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

function Material:_update(props)
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
            local mt = getmetatable(state.currTable)
            if mt == nil then
                return
            end
            state.currTable = mt.__index
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
    for topic, listener in allPairs(self.listeners) do
        local listener = listener
        scene.pub:subscribe(topic, function(args)
            listener(self, args)
        end)
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