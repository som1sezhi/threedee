local tdMath = require 'threedee.math'
local class  = require 'threedee.class'
local OrientedObject  = require 'threedee.OrientedObject'
-- local Vec3 = tdMath.Vec3
-- local sin = math.sin
-- local cos = math.cos

---@class Camera: OrientedObject

---@class PerspectiveCamera: Camera
---@field fov number
---@field aspectRatio number
---@field nearDist number
---@field farDist number
---@field projMatrix Mat4
local PerspectiveCamera = class('PerspectiveCamera', OrientedObject)

---@class(partial) PerspectiveCamera.Partial: PerspectiveCamera

---@param attrs PerspectiveCamera.Partial
---@return PerspectiveCamera
function PerspectiveCamera:new(attrs)
    local o = OrientedObject.new(self, attrs.position, attrs.rotation)
    o.fov = attrs.fov or math.rad(45)
    o.aspectRatio = attrs.aspectRatio or SCREEN_WIDTH / SCREEN_HEIGHT
    o.nearDist = attrs.nearDist or 1
    o.farDist = attrs.farDist or 2000
    o:updateProjMatrix()
    return o
end

-- ---@param target Vec3
-- function PerspectiveCamera:lookAt(target)
--     self.viewMatrix = tdMath.lookAt(self.position, target, self.worldUp)
-- end

-- function PerspectiveCamera:updateViewMatrix()
--     local front = Vec3:new(
--         cos(self.yaw) * cos(self.pitch),
--         sin(self.pitch),
--         sin(self.yaw) * cos(self.pitch)
--     )
--     self.viewMatrix = tdMath.lookAt(self.position, self.position + front, self.worldUp)
-- end

function PerspectiveCamera:updateProjMatrix()
    self.projMatrix = tdMath.perspective(
        self.fov, self.aspectRatio, self.nearDist, self.farDist
    )
end

return {
    PerspectiveCamera = PerspectiveCamera
}