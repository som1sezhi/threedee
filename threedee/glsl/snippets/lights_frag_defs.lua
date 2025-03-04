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
        vec3 position;
    };
    uniform PointLight pointLights[NUM_POINT_LIGHTS];
#endif
#if defined(NUM_POINT_LIGHT_SHADOWS) && NUM_POINT_LIGHT_SHADOWS > 0
    varying vec4 pointLightSpacePos[NUM_POINT_LIGHT_SHADOWS];

    uniform sampler2D pointLightShadowMaps[NUM_POINT_LIGHT_SHADOWS];
    uniform ShadowInfo pointLightShadows[NUM_POINT_LIGHT_SHADOWS];
#endif

#if defined(NUM_DIR_LIGHTS) && NUM_DIR_LIGHTS > 0
    struct DirLight {
        vec3 color;
        vec3 direction;
    };
    uniform DirLight dirLights[NUM_DIR_LIGHTS];
#endif
#if defined(NUM_DIR_LIGHT_SHADOWS) && NUM_DIR_LIGHT_SHADOWS > 0
    varying vec4 dirLightSpacePos[NUM_DIR_LIGHT_SHADOWS];

    uniform sampler2D dirLightShadowMaps[NUM_DIR_LIGHT_SHADOWS];
    uniform ShadowInfo dirLightShadows[NUM_DIR_LIGHT_SHADOWS];
#endif

#if defined(NUM_SPOT_LIGHTS) && NUM_SPOT_LIGHTS > 0
    struct SpotLight {
        vec3 color;
        vec3 position;
        vec3 direction;
        float cosAngle;
        float cosInnerAngle;
    };
    uniform SpotLight spotLights[NUM_SPOT_LIGHTS];
#endif
#if defined(NUM_SPOT_LIGHT_SHADOWS) && NUM_SPOT_LIGHT_SHADOWS > 0
    varying vec4 spotLightSpacePos[NUM_SPOT_LIGHT_SHADOWS];

    uniform sampler2D spotLightShadowMaps[NUM_SPOT_LIGHT_SHADOWS];
    uniform ShadowInfo spotLightShadows[NUM_SPOT_LIGHT_SHADOWS];
#endif
]],
    prevStageDeps = {'lights_vert'}
}
