return {
    snippet = [[
    #if defined(NUM_POINT_LIGHT_SHADOWS) && NUM_POINT_LIGHT_SHADOWS > 0
        for (int i = 0; i < NUM_POINT_LIGHT_SHADOWS; i++) {
            pointLightSpacePos[i] = pointLightMatrices[i] * worldPos;
        }
    #endif
]],
    deps = {'lights_vert_defs', 'position_vert'}
}