local class = require 'threedee.class'

---Base class for anything that needs an :update() method
---@class Updatable
local Updatable = class('Updatable')

---Updates `self` by setting the fields specified by the keys in `updates` to
---their corresponding values.
---@param updates table
function Updatable:update(updates)
    self:_update(updates)
    self:onUpdate(updates)
end

---Intended for updating fields and objects owned by `self`.
---@protected
---@param updates table
function Updatable:_update(updates)
    for k, v in pairs(updates) do
        self[k] = v
    end
end

---Intended for updating fields and objects outside of `self` that still
---need to know about changes to `self`.
---@param updates table
function Updatable:onUpdate(updates)
end

return Updatable