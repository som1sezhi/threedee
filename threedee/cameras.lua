local Mat4 = require 'threedee.math.Mat4'
local class  = require 'threedee.class'
local OrientedObject  = require 'threedee.OrientedObject'

---@class Camera: OrientedObject
---@field projMatrix Mat4
---@field nearDist number
---@field farDist number
---@field protected _projMatWasUpdated boolean

--------------------------------------------------------------------------------

---@class PerspectiveCamera: Camera
---@field fov number
---@field aspectRatio number
local PerspectiveCamera = class('PerspectiveCamera', OrientedObject)

---@class(partial) PerspectiveCamera.P: PerspectiveCamera, OrientedObject.P

---@param attrs PerspectiveCamera.P
---@return PerspectiveCamera
function PerspectiveCamera:new(attrs)
    local o = OrientedObject.new(self, attrs.position, attrs.rotation)
    o.fov = attrs.fov or math.rad(45)
    o.aspectRatio = attrs.aspectRatio or SCREEN_WIDTH / SCREEN_HEIGHT
    o.nearDist = attrs.nearDist or 1
    o.farDist = attrs.farDist or 2000
    o.projMatrix = Mat4:new()
    o._projMatWasUpdated = false
    o:_updateProjMatrix()
    return o
end

---@type fun(self: PerspectiveCamera, props: PerspectiveCamera.P)
PerspectiveCamera.set = OrientedObject.set

---@param props PerspectiveCamera.P
function PerspectiveCamera:_set(props)
    OrientedObject._set(self, props)
    if props.fov or props.aspectRatio or props.nearDist or props.farDist then
        self:_updateProjMatrix()
        self._projMatWasUpdated = true
    end
end

function PerspectiveCamera:_updateProjMatrix()
    self.projMatrix:perspective(
        self.fov, self.aspectRatio, self.nearDist, self.farDist
    )
end

--------------------------------------------------------------------------------

---@class OrthographicCamera: Camera
---@field left number
---@field right number
---@field top number
---@field bottom number
local OrthographicCamera = class('OrthographicCamera', OrientedObject)

---@class(partial) OrthographicCamera.P: OrthographicCamera, OrientedObject.P

---@param attrs OrthographicCamera.P
---@return OrthographicCamera
function OrthographicCamera:new(attrs)
    local o = OrientedObject.new(self, attrs.position, attrs.rotation)
    o.left = attrs.left or -SCREEN_CENTER_X -- SCREEN_WIDTH / 2
    o.right = attrs.right or SCREEN_CENTER_X
    o.top = attrs.top or -SCREEN_CENTER_Y -- SCREEN_HEIGHT / 2
    o.bottom = attrs.bottom or SCREEN_CENTER_Y
    o.nearDist = attrs.nearDist or 1
    o.farDist = attrs.farDist or 2000
    o.projMatrix = Mat4:new()
    o._projMatWasUpdated = false
    o:_updateProjMatrix()
    return o
end

---@type fun(self: OrthographicCamera, props: OrthographicCamera.P)
OrthographicCamera.set = OrientedObject.set

---@param props OrthographicCamera.P
function OrthographicCamera:_set(props)
    OrientedObject._set(self, props)
    if props.left or props.right or props.top or props.bottom or props.nearDist or props.farDist then
        self:_updateProjMatrix()
        self._projMatWasUpdated = true
    end
end

function OrthographicCamera:_updateProjMatrix()
    self.projMatrix:orthographic(
        self.left, self.right, self.top, self.bottom, self.nearDist, self.farDist
    )
end

return {
    PerspectiveCamera = PerspectiveCamera,
    OrthographicCamera = OrthographicCamera
}