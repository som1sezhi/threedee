return {
    snippet = [[
#if defined(NUM_POINT_LIGHT_SHADOWS) && NUM_POINT_LIGHT_SHADOWS > 0
    varying vec4 pointLightSpacePos[NUM_POINT_LIGHT_SHADOWS];
    uniform mat4 pointLightMatrices[NUM_POINT_LIGHT_SHADOWS];
#endif
]]
}