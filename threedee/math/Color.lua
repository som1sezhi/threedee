local Vec3 = require 'threedee.math.Vec3'

---A table containing utilities for handling color.
---
---Calling the table directly, like `color(r, g, b)`, is equivalent
---to `color.srgb(r, g, b)`.
---@overload fun(r: number, g: number, b: number): Vec3
local color = {}

---Creates a Vec3 representing the given linear RGB color.
---@param r number
---@param g number
---@param b number
---@return Vec3
function color.linrgb(r, g, b)
    return Vec3:new(r, g, b)
end

---Creates a Vec3 representing the given sRGB color.
---@param r number
---@param g number
---@param b number
---@return Vec3
function color.srgb(r, g, b)
    return Vec3:new(r ^ 2.2, g ^ 2.2, b ^ 2.2)
end

setmetatable(color --[[@as table]], {
    __call = function(self, r, g, b)
        return self.srgb(r, g, b)
    end
})

return color