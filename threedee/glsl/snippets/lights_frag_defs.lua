return {
    snippet = [[
#ifdef USE_AMBIENT_LIGHT
    uniform vec3 ambientLight;
#endif

struct ShadowInfo {
    float nearDist;
    float farDist;
};

#if defined(NUM_POINT_LIGHTS) && NUM_POINT_LIGHTS > 0
    struct PointLight {
        vec3 color;
        float intensity;
        vec3 position;
        bool castShadows;
    };
    uniform PointLight pointLights[NUM_POINT_LIGHTS];
#endif
#if defined(NUM_POINT_LIGHT_SHADOWS) && NUM_POINT_LIGHT_SHADOWS > 0
    varying vec4 pointLightSpacePos[NUM_POINT_LIGHT_SHADOWS];

    uniform sampler2D pointLightShadowMaps[NUM_POINT_LIGHT_SHADOWS];
    uniform ShadowInfo pointLightShadows[NUM_POINT_LIGHT_SHADOWS];
#endif
]],
    prevStageDeps = {'lights_vert'}
}
