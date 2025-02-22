local class = require 'threedee.class'
local mixins = require 'threedee.materials.mixins'
local AlphaMapMixin = mixins.AlphaMapMixin
local AlphaMixin = mixins.AlphaMixin

---A wrapped actor.
---@class SceneActor: Actor
---@field actor Actor
---@field scene Scene
local SceneActor = class('SceneActor')

---@generic A : SceneActor
---@param self A
---@param actor Actor
---@return A
function SceneActor.new(self, actor)
    local o = { actor = actor }
    return setmetatable(o, self)
end

function SceneActor:__index(key)
    local val = getmetatable(self)[key]
    if val ~= nil then return val end
    -- act as a wrapper around the actor
    val = self.actor[key]
    if type(val) == 'function' then
        -- assume this is an actor method.
        -- the first time this method is called, we inspect the return value
        -- and replace the method with an appropriate wrapper method for
        -- future invocations
        return function(...)
            arg[1] = self.actor
            local returns = {val(unpack(arg))}
            if #returns == 1 and returns[1] == self.actor then
                -- this method returns the actor itself (i.e. it can chain).
                -- handle this by having the method return the SceneActor instead
                self[key] = function(...)
                    arg[1] = self.actor
                    val(unpack(arg))
                    return self
                end
                return self
            else
                self[key] = function(...)
                    arg[1] = self.actor
                    return val(unpack(arg))
                end
                return unpack(returns)
            end
        end
    else
        return val
    end
end

---Sets the actor's (first layer) X/Y/Z scale values all at once
---@param scaleX number
---@param scaleY number
---@param scaleZ number
---@return SceneActor
function SceneActor:zoomxyz(scaleX, scaleY, scaleZ)
    self.actor:zoomx(scaleX)
    self.actor:zoomy(scaleY)
    self.actor:zoomz(scaleZ)
    return self
end

---Sets the actor's X/Y/Z scale to a uniform value
---@param scale number
---@return SceneActor
function SceneActor:scale(scale)
    self.actor:zoom(scale)
    self.actor:zoomz(scale)
    return self
end

---Called during Scene:finalize().
---@param scene Scene
function SceneActor:onFinalize(scene)
    self.scene = scene
end

function SceneActor:__tostring()
---@diagnostic disable-next-line: undefined-field
    return string.format('<%s "%s">', self.__name, self.actor:GetName())
end

--------------------------------------------------------------------------------

---A Sprite, Model, or Polygon associated with a material.
---@class ActorWithMaterial: SceneActor
---@field material Material
local ActorWithMaterial = class('ActorWithMaterial', SceneActor)

---@param actor Sprite | Model | Polygon | ActorWithMaterial
---@param material Material
function ActorWithMaterial:new(actor, material)
    local o = SceneActor.new(self, actor)
    o.material = material
    actor:zbuffer(1)
    actor:zwrite(1)
    actor:ztestmode('writeonpass')
    return o
end

function ActorWithMaterial:onFinalize(scene)
    SceneActor.onFinalize(self, scene)
    self.actor:SetShader(self.material.shader)
end

function ActorWithMaterial:Draw()
    if self.scene._isDrawingShadowMap then
        local depthMat = self.scene._overrideMaterial --[[@as DepthMaterial]]
        ---@diagnostic disable-next-line: undefined-field
        depthMat.alphaMap = self.material.colorMap
        ---@diagnostic disable-next-line: undefined-field
        depthMat.useVertexColors = self.material.useVertexColors and true or false
        ---@diagnostic disable-next-line: undefined-field
        depthMat.opacity = self.material.opacity
        -- update uniforms related to alpha for depth material
        AlphaMapMixin.onFrameStart(depthMat, self.scene)
        AlphaMixin.onFrameStart(depthMat, self.scene)
        self.actor:Draw()
    else
        self.material:onBeforeDraw(self)
        self.actor:Draw()
    end
end

--------------------------------------------------------------------------------

---A notefield proxy associated with a material.
---@class NoteFieldProxy: SceneActor
---@field material Material
---@field player Player
local NoteFieldProxy = class('NoteFieldProxy', SceneActor)

---Creates a new wrapped notefield proxy, and sets the proxy target to the
---player's notefield.
---@param actor ActorProxy | NoteFieldProxy
---@param material Material
---@param player Player
function NoteFieldProxy:new(actor, material, player)
    local o = SceneActor.new(self, actor)
    o.material = material
    o.player = player
    actor:SetTarget(player:GetChild('NoteField'))
    return o
end

function NoteFieldProxy:onFinalize(scene)
    SceneActor.onFinalize(self, scene)
    local shader = self.material.shader
    self.player:SetArrowShader(shader)
	self.player:SetHoldShader(shader)
	self.player:SetReceptorShader(shader)
    self.player:SetArrowPathShader(shader)
end

function NoteFieldProxy:Draw()
    if self.scene._isDrawingShadowMap then
        local depthMat = self.scene._overrideMaterial --[[@as DepthMaterial]]
        ---@diagnostic disable-next-line: undefined-field
        depthMat.alphaMap = self.material.colorMap
        ---@diagnostic disable-next-line: undefined-field
        depthMat.useVertexColors = self.material.useVertexColors and true or false
        ---@diagnostic disable-next-line: undefined-field
        depthMat.opacity = self.material.opacity
        -- update uniforms related to alpha for depth material
        AlphaMapMixin.onFrameStart(depthMat, self.scene)
        AlphaMixin.onFrameStart(depthMat, self.scene)
        self.actor:Draw()
    else
        DISPLAY:ShaderFuck(self.material.shader)
        self.material:onBeforeDraw(self)
        self.actor:Draw()
        DISPLAY:ClearShaderFuck()
    end
end

--------------------------------------------------------------------------------

return {
    SceneActor = SceneActor,
    ActorWithMaterial = ActorWithMaterial,
    NoteFieldProxy = NoteFieldProxy
}