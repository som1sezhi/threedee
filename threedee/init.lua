local math = require 'threedee.math'

local td = {
    Vec3 = math.Vec3,
    Vec4 = math.Vec4,
    Mat4 = math.Mat4,
    Color = math.Color,

    Scene = require 'threedee.Scene',
    PerspectiveCamera = require 'threedee.Camera',
    Object = require 'threedee.Object',

    PhongMaterial = require 'threedee.material.PhongMaterial',
}

---@param player Player
---@param material Material
function td.setMaterialOnPlayer(player, material)
    local shader = material.program
    player:SetArrowShader(shader)
	player:SetHoldShader(shader)
	player:SetReceptorShader(shader)
    player:SetArrowPathShader(shader)
end

---@param player Player
function td.clearMaterialOnPlayer(player)
    player:ClearArrowShader()
	player:ClearHoldShader()
	player:ClearReceptorShader()
end

return td