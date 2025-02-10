local class = require 'threedee.class'

---@class Object
---@field actor Actor
---@field material Material
local Object = class('Object')

---@param actor Actor
---@param material Material
---@return Object
function Object:new(actor, material)
    local o = {
        actor = actor,
        material = material,
    }
    o = setmetatable(o, self)
---@diagnostic disable-next-line: undefined-field
    if actor.SetTarget == nil then
        -- actor:SetShader(material.program)
        actor:zbuffer(1)
        actor:zwrite(1)
        actor:ztestmode('writeonpass')
    end
    return o
end

-- experiment with wrapping an actor
--[[
function Object:__index(key)
    local val = Object[key]
    if val ~= nil then return val end
    -- act as a wrapper around the actor
    val = self.actor[key]
    if type(val) == 'function' then
        -- assume this is an actor method
        local wrappedMethod = function(...)
            arg[1] = self.actor
            local returns = {val(unpack(arg))}
            if #returns == 1 and returns[1] == self.actor then
                -- this method returns the actor itself (i.e. it can chain)
                -- handle this by having the method return the Object instead
                self[val] = function(...)
                    arg[1] = self.actor
                    val(unpack(arg))
                    return self
                end
                return self
            else
                self[val] = function(...)
                    arg[1] = self.actor
                    return val(unpack(arg))
                end
                return unpack(returns)
            end
        end
        return wrappedMethod
    else
        return val
    end
end

function Object:zoomxyz(scaleX, scaleY, scaleZ)
    self.actor:zoomx(scaleX)
    self.actor:zoomy(scaleY)
    self.actor:zoomz(scaleZ)
    return self
end
]]

return Object