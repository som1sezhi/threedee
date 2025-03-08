local class = require 'threedee.class'
local mixins = require 'threedee.materials.mixins'
local AlphaMapMixin = mixins.AlphaMapMixin
local AlphaMixin = mixins.AlphaMixin

---A wrapped actor.
---@class SceneActor: Actor
---@field actor Actor
---@field scene Scene
local SceneActor = class('SceneActor')

---@generic A: SceneActor
---@param self A
---@param actor Actor
---@return A
function SceneActor.new(self, actor)
    local o = {
        actor = actor
    }
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
function SceneActor:finalize(scene)
    self.scene = scene
end

function SceneActor:__tostring()
---@diagnostic disable-next-line: undefined-field
    return string.format('<%s "%s">', self.__name, self.actor:GetName())
end

--------------------------------------------------------------------------------

---A SceneActor that wraps an ActorFrame.
---@class SceneActorFrame: SceneActor
---@field actor ActorFrame
---@field children SceneActor[]
local SceneActorFrame = class('SceneActorFrame', SceneActor)

---@param aframe ActorFrame | SceneActorFrame
---@return SceneActorFrame
function SceneActorFrame:new(aframe)
    local o = SceneActor.new(self, aframe)
    o.children = {}

    -- use a drawfunction to draw the children, in order to take advantage
    -- of ActorFrame matrix stack pushing/popping behavior to transform the
    -- children correctly.
    -- after this, a user can set their own custom draw function if they wish to,
    -- using the regular :SetDrawFunction method
    aframe:SetDrawFunction(function()
        for _, child in ipairs(o.children) do
            child:Draw()
        end
    end)

    return o
end

---Add a child or children to this SceneActorFrame. The children
---should all wrap an actual child of the underlying ActorFrame.
---@param sceneActor SceneActor | SceneActor[]
function SceneActorFrame:add(sceneActor)
    local len = #sceneActor
    if len > 0 then
        -- assume this is a table of sceneactors
        for i = 1, len do
            table.insert(self.children, sceneActor[i])
        end
    else
        -- assume this is just one sceneactor
        table.insert(self.children, sceneActor)
    end
end

function SceneActorFrame:finalize(scene)
    SceneActor.finalize(self, scene)
    for _, child in ipairs(self.children) do
        child:finalize(scene)
    end
end

--------------------------------------------------------------------------------

---A SceneActor associated with a material.
---@class ActorWithMaterial: SceneActor
---@field material Material
---@field castShadows boolean
---@field receiveShadows boolean
local ActorWithMaterial = class('ActorWithMaterial', SceneActor)

---@generic A: ActorWithMaterial
---@param self A
---@param actor Actor
---@param material Material
---@return A
function ActorWithMaterial:new(actor, material)
    local o = SceneActor.new(self, actor)
    o.material = material
    o.castShadows = false
    o.receiveShadows = false
    return o
end

---@param overrideMaterial DepthMaterial
function ActorWithMaterial:_prepareOverrideMaterialAlpha(overrideMaterial)
    local mat = self.material
    overrideMaterial:update({
        ---@diagnostic disable-next-line: undefined-field
        alphaMap = mat.colorMap or mat.alphaMap or false,
        ---@diagnostic disable-next-line: undefined-field
        useVertexColorAlpha = (mat.useVertexColors or mat.useVertexColorAlpha) and true or false,
        ---@diagnostic disable-next-line: undefined-field
        opacity = mat.opacity or 1
    })
end

--------------------------------------------------------------------------------

---A Sprite, Model, or Polygon associated with a material.
---@class MeshActor: ActorWithMaterial
---@field cullMode 'none'|'front'|'back'
---@field shadowCullMode 'none'|'front'|'back'
local MeshActor = class('MeshActor', ActorWithMaterial)

---@param actor Sprite | Model | Polygon | MeshActor
---@param material Material
function MeshActor:new(actor, material)
    local o = ActorWithMaterial.new(self, actor, material)
    o.shadowCullMode = 'none'
    o.cullMode = 'back'
    actor:zbuffer(1)
    actor:zwrite(1)
    actor:ztestmode('writeonpass')
    return o
end

function MeshActor:finalize(scene)
    ActorWithMaterial.finalize(self, scene)
    self.actor:SetShader(self.material.shader)
end

function MeshActor:Draw()
    if self.scene._isDrawingShadowMap then
        if self.castShadows then
            local depthMat = self.scene._overrideMaterial --[[@as DepthMaterial]]
            self:_prepareOverrideMaterialAlpha(depthMat)
            self.actor:cullmode(self.shadowCullMode)
            self.actor:Draw()
        end
    else
        self.material:onBeforeDraw(self)
        self.actor:cullmode(self.cullMode)
        self.actor:Draw()
    end
end

--------------------------------------------------------------------------------

---A notefield proxy associated with a material.
---@class NoteFieldProxy: ActorWithMaterial
---@field player Player
local NoteFieldProxy = class('NoteFieldProxy', ActorWithMaterial)

---Creates a new wrapped notefield proxy, and sets the proxy target to the
---player's notefield.
---@param actor ActorProxy | NoteFieldProxy
---@param material Material
---@param player Player
function NoteFieldProxy:new(actor, material, player)
    local o = ActorWithMaterial.new(self, actor, material)
    o.player = player
    actor:SetTarget(player:GetChild('NoteField'))
    return o
end

function NoteFieldProxy:finalize(scene)
    ActorWithMaterial.finalize(self, scene)
    local shader = self.material.shader
    -- probably don't need to do this since we use shaderfuck but eh
    self.player:SetArrowShader(shader)
	self.player:SetHoldShader(shader)
	self.player:SetReceptorShader(shader)
    self.player:SetArrowPathShader(shader)
end

function NoteFieldProxy:Draw()
    if self.scene._isDrawingShadowMap then
        if self.castShadows then
            local depthMat = self.scene._overrideMaterial --[[@as DepthMaterial]]
            self:_prepareOverrideMaterialAlpha(depthMat)
            self.actor:Draw()
        end
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
    SceneActorFrame = SceneActorFrame,
    MeshActor = MeshActor,
    NoteFieldProxy = NoteFieldProxy
}