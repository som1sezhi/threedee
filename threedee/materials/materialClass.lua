local class = require 'threedee.class'

---Creates a new material class inheriting from parentClass, incorporating the given mixins.
---@param name string
---@param parentClass Material
---@param mixins MaterialMixin[]
---@return Material
local function materialClass(name, parentClass, mixins)
    ---@type Material
    local cls = class(name, parentClass)

    cls.mixins = {unpack(parentClass.mixins)} -- shallow copy
    -- parent's changeFuncs already contain inherited mixins' changeFuncs, so we can
    -- just look there as fallback
    cls.changeFuncs = setmetatable({}, {__index = parentClass.changeFuncs})
    -- same with listeners
    cls.listeners = setmetatable({}, {__index = parentClass.listeners})

    -- incorporate new mixins into the class
    for _, mixin in ipairs(mixins) do
        table.insert(cls.mixins, mixin)
        -- add new changeFuncs
        if mixin.changeFuncs then
            for k, changeFunc in pairs(mixin.changeFuncs) do
                cls.changeFuncs[k] = changeFunc
            end
        end
        -- add new listeners
        if mixin.listeners then
            for k, listeners in pairs(mixin.listeners) do
                cls.listeners[k] = listeners
            end
        end
    end
    
    return cls
end

return materialClass