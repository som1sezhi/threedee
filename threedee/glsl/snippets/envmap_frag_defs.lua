return {
    snippet = [[
#ifdef USE_ENV_MAP
    uniform sampler2D envMap;
    uniform float envMapStrength;
    uniform mat3 envMapRotation;
    #ifdef ENV_MAP_TYPE_REFRACTION
        uniform float refractionRatio;
    #endif
#endif
]],
    deps = {}
}
