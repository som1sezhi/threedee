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
            float attenuation = 1. / (
                1.
                + light.linearAttenuation * lightDist
                + light.quadraticAttenuation * lightDist * lightDist
            );

            #if defined(NUM_POINT_LIGHT_SHADOWS) && NUM_POINT_LIGHT_SHADOWS > 0
                if (i < NUM_POINT_LIGHT_SHADOWS && doShadows) {
                    vec3 projCoord = calcShadowProjCoord(
                        pointLightSpacePos[i], pointLightShadows[i]
                    );
                    float shadow = calcShadow(
                        projCoord,
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

    #if defined(NUM_DIR_LIGHTS) && NUM_DIR_LIGHTS > 0
        for (int i = 0; i < NUM_DIR_LIGHTS; i++) {
            DirLight light = dirLights[i];
            vec3 incomingLight = light.color;
            vec3 lightDir = -normalize(light.direction);

            #if defined(NUM_DIR_LIGHT_SHADOWS) && NUM_DIR_LIGHT_SHADOWS > 0
                if (i < NUM_DIR_LIGHT_SHADOWS && doShadows) {
                    vec3 projCoord = calcShadowProjCoordOrtho(dirLightSpacePos[i]);
                    float shadow = calcShadow(
                        projCoord,
                        dirLightShadowMaps[i],
                        dirLightShadows[i]
                    );
                    incomingLight *= (1.0 - shadow);
                }
            #endif

            outgoingLight += getOutgoingLight(
                incomingLight, lightDir, viewDir, normal, material
            );
        }
    #endif

    #if defined(NUM_SPOT_LIGHTS) && NUM_SPOT_LIGHTS > 0
        for (int i = 0; i < NUM_SPOT_LIGHTS; i++) {
            SpotLight light = spotLights[i];
            vec3 incomingLight = light.color;
            vec3 lightDir = light.position - vWorldPos;
            float lightDist = length(lightDir);
            lightDir /= lightDist;
            float attenuation = 1. / (
                1.
                + light.linearAttenuation * lightDist
                + light.quadraticAttenuation * lightDist * lightDist
            );
        
            float theta = dot(lightDir, -normalize(light.direction));
            float epsilon = light.cosInnerAngle - light.cosAngle;
            attenuation *= clamp((theta - light.cosAngle) / epsilon, 0.0, 1.0);

            #if defined(NUM_SPOT_LIGHT_MATRICES) && NUM_SPOT_LIGHT_MATRICES > 0
                if (i < NUM_SPOT_LIGHT_MATRICES && attenuation > 0.0) {
                    #if defined(NUM_SPOT_LIGHT_SHADOWS) && NUM_SPOT_LIGHT_SHADOWS > 0
                        vec3 projCoord = calcShadowProjCoord(
                            spotLightSpacePos[i], spotLightShadows[i]
                        );
                        if (i < NUM_SPOT_LIGHT_SHADOWS && doShadows) {
                            float shadow = calcShadow(
                                projCoord,
                                spotLightShadowMaps[i],
                                spotLightShadows[i]
                            );
                            attenuation *= (1.0 - shadow);
                        }
                    #else
                        vec2 projCoord = spotLightSpacePos[i].xy / spotLightSpacePos[i].w;
                    #endif
                    #if defined(NUM_SPOT_LIGHT_COLOR_MAPS) && NUM_SPOT_LIGHT_COLOR_MAPS > 0
                        #ifndef NUM_SPOT_LIGHT_SHADOWS
                            #define NUM_SPOT_LIGHT_SHADOWS 0
                        #endif
                        #define NUM_COLOR_MAPS_WITHOUT_SHADOW (NUM_SPOT_LIGHT_MATRICES - NUM_SPOT_LIGHT_SHADOWS)
                        #define NUM_COLOR_MAPS_WITH_SHADOW (NUM_SPOT_LIGHT_COLOR_MAPS - NUM_COLOR_MAPS_WITHOUT_SHADOW)
                        if (i < NUM_COLOR_MAPS_WITH_SHADOW) {
                            incomingLight *= texture2D(
                                spotLightColorMaps[i],
                                projCoord.xy * 0.5 + 0.5
                            ).rgb;
                        } else if (i >= NUM_SPOT_LIGHT_SHADOWS) {
                            incomingLight *= texture2D(
                                spotLightColorMaps[NUM_COLOR_MAPS_WITH_SHADOW + (i - NUM_SPOT_LIGHT_SHADOWS)],
                                projCoord.xy * 0.5 + 0.5
                            ).rgb;
                        }
                    #endif
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
