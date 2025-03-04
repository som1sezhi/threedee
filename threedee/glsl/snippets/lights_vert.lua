return {
    snippet = [[
    #if defined(NUM_POINT_LIGHT_SHADOWS) && NUM_POINT_LIGHT_SHADOWS > 0
        for (int i = 0; i < NUM_POINT_LIGHT_SHADOWS; i++) {
            pointLightSpacePos[i] = pointLightMatrices[i] * worldPos;
        }
    #endif
    #if defined(NUM_DIR_LIGHT_SHADOWS) && NUM_DIR_LIGHT_SHADOWS > 0
        for (int i = 0; i < NUM_DIR_LIGHT_SHADOWS; i++) {
            dirLightSpacePos[i] = dirLightMatrices[i] * worldPos;
        }
    #endif
]],
    deps = {'lights_vert_defs', 'position_vert'}
}