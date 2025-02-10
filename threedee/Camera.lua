local tdMath = require 'threedee.math'
local class  = require 'threedee.class'
local Vec3 = tdMath.Vec3
local sin = math.sin
local cos = math.cos

---@class PerspectiveCamera
---@field position Vec3
---@field yaw number yaw (radians)
---@field pitch number pitch (radians)
---@field worldUp Vec3
---@field fov number
---@field aspectRatio number
---@field nearDist number
---@field farDist number
---@field viewMatrix Mat4
---@field projMatrix Mat4
local PerspectiveCamera = class('PerspectiveCamera')

function PerspectiveCamera:new(attrs)
    local o = {
        position = attrs.position or Vec3:new(0, 0, 0),
        yaw = attrs.yaw or math.rad(90),
        pitch = attrs.pitch or math.rad(0),
        worldUp = attrs.worldUp or Vec3:new(0, -1, 0),
        fov = attrs.fov or math.rad(45),
        aspectRatio = attrs.aspectRatio or SCREEN_WIDTH / SCREEN_HEIGHT,
        nearDist = attrs.nearDist or 1,
        farDist = attrs.farDist or 2000,
    }
    o = setmetatable(o, self)
    o:updateViewMatrix()
    o:updateProjMatrix()
    return o
end

---@param target Vec3
function PerspectiveCamera:lookAt(target)
    self.viewMatrix = tdMath.lookAt(self.position, target, self.worldUp)
end

function PerspectiveCamera:updateViewMatrix()
    local front = Vec3:new(
        cos(self.yaw) * cos(self.pitch),
        sin(self.pitch),
        sin(self.yaw) * cos(self.pitch)
    )
    self.viewMatrix = tdMath.lookAt(self.position, self.position + front, self.worldUp)
end

function PerspectiveCamera:updateProjMatrix()
    self.projMatrix = tdMath.perspective(
        self.fov, self.aspectRatio, self.nearDist, self.farDist
    )
end

return PerspectiveCamera