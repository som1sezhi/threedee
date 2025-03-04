return {
    snippet = [[
#if defined(NUM_POINT_LIGHT_SHADOWS) && NUM_POINT_LIGHT_SHADOWS > 0
    varying vec4 pointLightSpacePos[NUM_POINT_LIGHT_SHADOWS];
    uniform mat4 pointLightMatrices[NUM_POINT_LIGHT_SHADOWS];
#endif
#if defined(NUM_DIR_LIGHT_SHADOWS) && NUM_DIR_LIGHT_SHADOWS > 0
    varying vec4 dirLightSpacePos[NUM_DIR_LIGHT_SHADOWS];
    uniform mat4 dirLightMatrices[NUM_DIR_LIGHT_SHADOWS];
#endif
#if defined(NUM_SPOT_LIGHT_SHADOWS) && NUM_SPOT_LIGHT_SHADOWS > 0
    varying vec4 spotLightSpacePos[NUM_SPOT_LIGHT_SHADOWS];
    uniform mat4 spotLightMatrices[NUM_SPOT_LIGHT_SHADOWS];
#endif
]]
}