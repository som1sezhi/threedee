---@param name string
---@param parentClass any
---@return table
local function class(name, parentClass)
    local cls = {
        __name = name,
    }
    if parentClass == nil then
        cls.__tostring = function(self) return string.format('<%s>', self.__name) end
        cls.__index = cls
    else
        cls.__tostring = parentClass.__tostring
        if type(parentClass.__index) == 'function' then
            cls.__index = parentClass.__index
        else
            cls.__index = cls
        end
    end
    return setmetatable(cls, {
        __index = parentClass,
        __tostring = function() return '<class ' .. name .. '>' end
    })
end

return class