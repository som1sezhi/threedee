return {
    snippet = [[
    #ifdef USE_ENV_MAP
    // TODO: correct view direction for ortho camera
        vec3 envMapSampleDir;
        #if defined(ENV_MAP_TYPE_REFLECTION)
            envMapSampleDir = reflect(-viewDir, normal);
        #elif defined(ENV_MAP_TYPE_REFRACTION)
            envMapSampleDir = refract(-viewDir, normal, refractionRatio);
        #else
            #error "unknown envMap type"
        #endif
        envMapSampleDir = envMapRotation * envMapSampleDir;

        vec2 envMapUV = getEnvMapUV(envMapSampleDir);
        vec3 envColor = srgb2Linear(texture2D(envMap, envMapUV).rgb);

        #if defined(ENV_MAP_COMBINE_MULTIPLY)
            outgoingLight = mix(outgoingLight, outgoingLight * envColor, envMapStrength);
        #elif defined(ENV_MAP_COMBINE_MIX)
            outgoingLight = mix(outgoingLight, envColor, envMapStrength);
        #elif defined(ENV_MAP_COMBINE_ADD)
            outgoingLight += envColor * envMapStrength;
        #else
            #error "unknown envMap combine function"
        #endif
    #endif
]],
    deps = {
        'envmap_frag_defs',
        'lights_frag',
        'mapping'
    }
}
