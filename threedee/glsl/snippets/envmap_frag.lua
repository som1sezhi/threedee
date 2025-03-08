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

        #ifdef SPECULAR_MAP_SAMPLE_DEFINED // see <phong_frag>
            vec3 envStrength = envMapStrength * specularMapSample;
        #else
            float envStrength = envMapStrength;
        #endif

        #if defined(ENV_MAP_COMBINE_MULTIPLY)
            outgoingLight = mix(outgoingLight, outgoingLight * envColor, envStrength);
        #elif defined(ENV_MAP_COMBINE_MIX)
            outgoingLight = mix(outgoingLight, envColor, envStrength);
        #elif defined(ENV_MAP_COMBINE_ADD)
            outgoingLight += envColor * envStrength;
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
