local class = require "threedee.class"
---@class Color
---@field [1] number
---@field [2] number
---@field [3] number
local Color = class('Color')

---@param r any
---@param g any
---@param b any
---@return Color
function Color:new(r, g, b)
    return setmetatable({r, g, b}, self)
end

function Color:fromSRGB(r, g, b)
    return Color:new(r ^ 2.2, g ^ 2.2, b ^ 2.2)
end

function Color:__tostring()
    return 'Color(' .. self[1] .. ',' .. self[2] .. ',' .. self[3] .. ')'
end

return Color