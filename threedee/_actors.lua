---@diagnostic disable: undefined-global

local actors = {
    ---@type Actor[]
    materialActors = _td_materialActors:GetChildren(),

    ---@type Actor
    depthMatActor = _td_depthMatActor,

    ---@type ActorFrameTexture[]
    shadowMapAfts = _td_shadowMapAfts:GetChildren(),

    ---@type Quad
    depthInitQuad = _td_depthInitQuad,

    ---@type Actor
    clearBufferActor = _td_clearBufferActor,

    ---TODO: remove?
    ---@type Sprite
    whiteSpr = _td_whiteSpr
}

local materialIdx = 1
function actors.getMaterialActor()
    local act = actors.materialActors[materialIdx]
    if act == nil then
        error('Currently, you can only create '..#actors.materialActors..' materials. If you want more, add more children inside the _td_materialActors ActorFrame in threedee.xml.')
    end
    materialIdx = materialIdx + 1
    return act
end

local shadowMapAftIdx = 1
function actors.getShadowMapAft()
    local act = actors.shadowMapAfts[shadowMapAftIdx]
    if act == nil then
        error('Currently, you can only create '..#actors.shadowMapAfts..' shadow maps. If you want more, add more AFTs inside the _td_shadowMapAfts ActorFrame in threedee.xml.')
    end
    shadowMapAftIdx = shadowMapAftIdx + 1
    return act
end

return actors