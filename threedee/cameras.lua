local Mat4 = require 'threedee.math.Mat4'
local class  = require 'threedee.class'
local OrientedObject  = require 'threedee.OrientedObject'

---Base class for all cameras.
---@class Camera: OrientedObject
---@field projMatrix Mat4 (R) The camera's projection matrix. Automatically updated whenever a camera property that would affect it is updated via `:update()`.
---@field nearDist number (U) Distance to the near plane. Geometry closer than this will be clipped. Default: `1`
---@field farDist number (U) Distance to the far plane. Geometry farther than this will be clipped. Default: `2000`
---@field protected _projMatWasUpdated boolean
local Camera = class('Camera', OrientedObject)

---@class (partial) Camera.P: Camera, OrientedObject.P

---@generic C: Camera
---@param self C
---@param attrs Camera.P
---@return C
function Camera:new(attrs)
    local o = OrientedObject.new(self, attrs.position, attrs.rotation)
    o.nearDist = attrs.nearDist or 1
    o.farDist = attrs.farDist or 2000
    o.projMatrix = Mat4:new()
    o._projMatWasUpdated = false
    return o
end

---@param scene Scene
function Camera:linkWithScene(scene)
    ---@param self Camera
    ---@param props Camera.P
    self.onUpdate = function(self, props)
        if props.position then
            scene.pub:sendMessage('cameraPos', { value = props.position })
        end
        if props.position or props.rotation or props.viewMatrix then
            scene.pub:sendMessage('viewMatrix', { value = self.viewMatrix })
        end
        if self._projMatWasUpdated then
            scene.pub:sendMessage('projMatrix', { value = self.projMatrix })
            self._projMatWasUpdated = false
        end
    end
end

---Force-update the projection matrix.
function Camera:updateProjMatrix()
end

--------------------------------------------------------------------------------

---A camera utilizing perspective projection.
---@class PerspectiveCamera: Camera
---@field fov number (U) The vertical FOV, in radians. Default: `math.rad(45)` (45 degrees)
---@field aspectRatio number (U) The aspect ratio of the camera frustum. Default: `SCREEN_WIDTH / SCREEN_HEIGHT`
local PerspectiveCamera = class('PerspectiveCamera', Camera)

---@class(partial) PerspectiveCamera.P: PerspectiveCamera, Camera.P

---Creates a new camera. `attrs` is a table that contains
---one or more camera properties that will be passed into the
---new camera; missing properties will be initialized with their
---defaults.
---@param attrs PerspectiveCamera.P
---@return PerspectiveCamera
function PerspectiveCamera:new(attrs)
    local o = Camera.new(self, {
        position = attrs.position,
        rotation = attrs.rotation,
        nearDist = attrs.nearDist,
        farDist = attrs.farDist
    })
    o.fov = attrs.fov or math.rad(45)
    o.aspectRatio = attrs.aspectRatio or SCREEN_WIDTH / SCREEN_HEIGHT
    o:updateProjMatrix()
    return o
end

---@type fun(self: PerspectiveCamera, props: PerspectiveCamera.P)
PerspectiveCamera.update = OrientedObject.update

---@param props PerspectiveCamera.P
function PerspectiveCamera:_update(props)
    OrientedObject._update(self, props)
    if props.fov or props.aspectRatio or props.nearDist or props.farDist then
        self:updateProjMatrix()
        self._projMatWasUpdated = true
    end
end

---Force-update the projection matrix.
function PerspectiveCamera:updateProjMatrix()
    self.projMatrix:perspective(
        self.fov, self.aspectRatio, self.nearDist, self.farDist
    )
end

--------------------------------------------------------------------------------

---A camera utilizing orthographic projection.
---@class OrthographicCamera: Camera
---@field left number (U) Left plane x-coordinate. Default: `-SCREEN_WIDTH / 2`
---@field right number (U) Right plane x-coordinate. Default: `SCREEN_WIDTH / 2`
---@field top number (U) Top plane y-coordinate. Default: `-SCREEN_HEIGHT / 2`
---@field bottom number (U) Bottom plane y-coordinate. Default: `SCREEN_HEIGHT / 2`
local OrthographicCamera = class('OrthographicCamera', Camera)

---@class(partial) OrthographicCamera.P: OrthographicCamera, Camera.P

---Creates a new camera. `attrs` is a table that contains
---one or more camera properties that will be passed into the
---new camera; missing properties will be initialized with their
---defaults.
---@param attrs OrthographicCamera.P
---@return OrthographicCamera
function OrthographicCamera:new(attrs)
    local o = Camera.new(self, {
        position = attrs.position,
        rotation = attrs.rotation,
        nearDist = attrs.nearDist,
        farDist = attrs.farDist
    })
    o.left = attrs.left or -SCREEN_CENTER_X -- SCREEN_WIDTH / 2
    o.right = attrs.right or SCREEN_CENTER_X
    o.top = attrs.top or -SCREEN_CENTER_Y -- SCREEN_HEIGHT / 2
    o.bottom = attrs.bottom or SCREEN_CENTER_Y
    o:updateProjMatrix()
    return o
end

---@type fun(self: OrthographicCamera, props: OrthographicCamera.P)
OrthographicCamera.update = OrientedObject.update

---@param props OrthographicCamera.P
function OrthographicCamera:_update(props)
    OrientedObject._update(self, props)
    if props.left or props.right or props.top or props.bottom or props.nearDist or props.farDist then
        self:updateProjMatrix()
        self._projMatWasUpdated = true
    end
end

---Force-update the projection matrix.
function OrthographicCamera:updateProjMatrix()
    self.projMatrix:orthographic(
        self.left, self.right, self.top, self.bottom, self.nearDist, self.farDist
    )
end

return {
    PerspectiveCamera = PerspectiveCamera,
    OrthographicCamera = OrthographicCamera
}