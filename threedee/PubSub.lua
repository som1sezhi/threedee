local class = require 'threedee.class'

---@alias Listener fun(args: table)

---@class PubSub
---@field listeners {[string]: Listener[]}
local PubSub = class('PubSub')

---@return PubSub
function PubSub:new()
    return setmetatable({ listeners = {} }, self)
end

---Register a listener
---@param topic string
---@param listener Listener
function PubSub:subscribe(topic, listener)
    if self.listeners[topic] then
        table.insert(self.listeners[topic], listener)
    else
        self.listeners[topic] = { listener }
    end
end

---Send a message to all listeners of a topic
---@param topic string
---@param args table
function PubSub:sendMessage(topic, args)
    if self.listeners[topic] then
        for _, listener in ipairs(self.listeners[topic]) do
            listener(args)
        end
    end
end

return PubSub
