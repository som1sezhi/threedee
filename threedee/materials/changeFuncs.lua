local cfs = {}

---@param name string
---@return ChangeFunc
function cfs.boolChangeFunc(name)
    return function(self, newVal)
        newVal = newVal or self[name]
        self.shader:uniform1i(name, newVal and 1 or 0)
    end
end

---@param name string
---@return ChangeFunc
function cfs.floatChangeFunc(name)
    return function(self, newVal)
        newVal = newVal or self[name]
        self.shader:uniform1f(name, newVal)
    end
end

---@param name string
---@return ChangeFunc
function cfs.vec3ChangeFunc(name)
    return function(self, newVal)
        newVal = newVal or self[name]
        self.shader:uniform3fv(name, newVal)
    end
end

---@param name string
---@return ChangeFunc
function cfs.mat3ChangeFunc(name)
    return function(self, newVal)
        newVal = newVal or self[name]
        self.shader:uniformMatrix3fv(name, newVal)
    end
end

---@param name string
---@return ChangeFunc
function cfs.optTextureChangeFunc(name)
    return function(self, newVal)
        newVal = newVal or self[name]
        if newVal then
            self.shader:uniformTexture(name, newVal)
        end
    end
end

return cfs