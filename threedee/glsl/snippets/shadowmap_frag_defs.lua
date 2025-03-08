return {
    snippet = [[
uniform bool doShadows;
uniform vec2 shadowMapTextureSize;
uniform vec2 shadowMapImageSize;

vec2 img2texShadowMap(vec2 v) {
    return v / shadowMapTextureSize * shadowMapImageSize;
}

vec2 img2texShadowMapNearest(vec2 v) {
    // nearest neighbour
    return (floor(v * shadowMapImageSize) + 0.5) / shadowMapTextureSize;
}

vec3 calcShadowProjCoord(vec4 fragLightSpacePos, ShadowInfo shadowInfo) {
    vec3 projCoord = fragLightSpacePos.xyz / fragLightSpacePos.w;
    projCoord.z = invlerp(
        shadowInfo.nearDist,
        shadowInfo.farDist,
        linearizeDepth(projCoord.z, shadowInfo.nearDist, shadowInfo.farDist)
    );
    return projCoord;
}

vec3 calcShadowProjCoordOrtho(vec4 fragLightSpacePos) {
    vec3 projCoord = fragLightSpacePos.xyz / fragLightSpacePos.w;
    projCoord.z = projCoord.z * 0.5 + 0.5;
    return projCoord;
}

// projCoord.xy = XY coords of fragment position projected in light space
// projCoord.z = depth of current fragment in [0, 1]
float calcShadow(vec3 projCoord, sampler2D shadowMap, ShadowInfo shadowInfo) {
    float currentDepth = projCoord.z;
    if (currentDepth < 0.0 || 1.0 < currentDepth)
        return 0.0;

    // no shadows outside the shadowmap's frame
    if (any(lessThan(projCoord.xy, vec2(-1.0))) || any(greaterThan(projCoord.xy, vec2(1.0))))
        return 0.0;

    // currentDepth -= max(0.01 * (1.0 - dot(nrm, light)), 0.002);
    currentDepth += shadowInfo.bias;
    projCoord.xy = projCoord.xy * 0.5 + 0.5;

    float shadow = 0.0;
    vec2 texelSize = 1. / shadowMapTextureSize;
    vec2 corner1 = 0.5 * texelSize;
    vec2 corner2 = shadowMapImageSize / shadowMapTextureSize - corner1;

    #define shadowSample(uv) (step(unpackRGBToDepth(texture2D(shadowMap, clamp(uv, corner1, corner2)).rgb), currentDepth))

    #if defined(SHADOWMAP_FILTER_PCF_SIMPLE)

        vec2 baseUV = img2texShadowMapNearest(projCoord.xy);

        shadow = (
            shadowSample(baseUV - texelSize)
            + shadowSample(baseUV + vec2(0.0, -texelSize.y))
            + shadowSample(baseUV + vec2(texelSize.x, -texelSize.y))
            + shadowSample(baseUV + vec2(-texelSize.x, 0.0))
            + shadowSample(baseUV)
            + shadowSample(baseUV + vec2(texelSize.x, 0.0))
            + shadowSample(baseUV + vec2(-texelSize.x, texelSize.y))
            + shadowSample(baseUV + vec2(0.0, texelSize.y))
            + shadowSample(baseUV + texelSize)
        ) / 9.0;
    
    #elif defined(SHADOWMAP_FILTER_PCF_BILINEAR)

        vec2 baseUV = img2texShadowMap(projCoord.xy);
        vec2 uvf = fract(baseUV * shadowMapTextureSize + 0.5);
        baseUV -= uvf * texelSize;

        // we sample a 4x4 region around baseUV to obtain a 3x3 grid
        // of bilinear samples.
        // note that the middle 2x2 grid of texels will always be added
        // to the final result with full weight, since bilinear samples are
        // taken on either side of those texels and their weights sum to 1.
        // you can then mix texels on opposite sides of the kernel using
        // the uvf.x/uvf.y weights to get equivalent results to bilinear sampling

        shadow = (
            shadowSample(baseUV)
            + shadowSample(baseUV + vec2(texelSize.x, 0.0))
            + shadowSample(baseUV + vec2(0.0, texelSize.y))
            + shadowSample(baseUV + texelSize)
            + mix(
                shadowSample(baseUV + vec2(-texelSize.x, 0.0)),
                shadowSample(baseUV + vec2(2.0 * texelSize.x, 0.0)),
                uvf.x
            )
            + mix(
                shadowSample(baseUV + vec2(-texelSize.x, texelSize.y)),
                shadowSample(baseUV + vec2(2.0 * texelSize.x, texelSize.y)),
                uvf.x
            )
            + mix(
                shadowSample(baseUV + vec2(0.0, -texelSize.y)),
                shadowSample(baseUV + vec2(0.0, 2.0 * texelSize.y)),
                uvf.y
            )
            + mix(
                shadowSample(baseUV + vec2(texelSize.x, -texelSize.y)),
                shadowSample(baseUV + vec2(texelSize.x, 2.0 * texelSize.y)),
                uvf.y
            )
            + mix(
                mix(
                    shadowSample(baseUV - texelSize),
                    shadowSample(baseUV + vec2(2.0 * texelSize.x, -texelSize.y)),
                    uvf.x
                ),
                mix(
                    shadowSample(baseUV + vec2(-texelSize.x, 2.0 * texelSize.y)),
                    shadowSample(baseUV + 2.0 * texelSize),
                    uvf.x
                ),
                uvf.y
            )
        ) / 9.0;

    #else // no filtering

        vec2 baseUV = img2texShadowMapNearest(projCoord.xy);
        shadow = shadowSample(baseUV);

    #endif

    return shadow;
}
]],
    deps = {'packing', 'lights_frag_defs', 'utils'}
}