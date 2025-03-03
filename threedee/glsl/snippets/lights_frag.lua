return {
    snippet = [[
    vec3 viewDir = normalize(vViewVec);
    vec3 outgoingLight = vec3(0.0);

    #ifdef USE_AMBIENT_LIGHT
        outgoingLight += fragBaseColor * ambientLight;
    #endif

    #if defined(NUM_POINT_LIGHTS) && NUM_POINT_LIGHTS > 0
        for (int i = 0; i < NUM_POINT_LIGHTS; i++) {
            PointLight light = pointLights[i];
            vec3 incomingLight = light.color;
            vec3 lightDir = light.position - vWorldPos;
            float lightDist = length(lightDir);
            lightDir /= lightDist;
            float attenuation = 1. / (1. + 0.000002 * lightDist * lightDist);

            #if defined(NUM_POINT_LIGHT_SHADOWS) && NUM_POINT_LIGHT_SHADOWS > 0
                if (i < NUM_POINT_LIGHT_SHADOWS && doShadows) {
                    float shadow = calcShadow(
                        pointLightSpacePos[i],
                        pointLightShadowMaps[i],
                        pointLightShadows[i]
                    );
                    attenuation *= (1.0 - shadow);
                }
            #endif

            incomingLight *= attenuation;

            outgoingLight += getOutgoingLight(
                incomingLight, lightDir, viewDir, normal, material
            );
        }
    #endif
]],
    deps = {
        'lights_frag_defs',
        'posvaryings_frag_defs',
        'color_frag',
        'shadowmap_frag_defs',
        'normal_frag'
    },
    traitDeps = {
        'defines_material',
        'defines_getOutgoingLight'
    }
}
