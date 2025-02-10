---@param name string
---@param parentClass any
---@return table
local function class(name, parentClass)
    local cls = {
        __name = name
    }
    cls.__index = cls
    return setmetatable(cls, {
        __index = parentClass,
        __tostring = function() return '<class ' .. name .. '>' end
    })
end

return class