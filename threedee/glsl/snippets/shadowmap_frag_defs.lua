return {
    snippet = [[
uniform bool doShadows;
uniform vec2 shadowMapTextureSize;
uniform vec2 shadowMapImageSize;

vec2 img2texShadowMap( vec2 v ) {
    //vec2 uv = v / shadowMapTextureSize * shadowMapImageSize;
    // nearest neighbour
    return (floor(v * shadowMapImageSize) + 0.5) / shadowMapTextureSize;
}

#define OLD
#ifdef OLD
float calcShadow(vec4 fragLightSpacePos, sampler2D shadowMap, ShadowInfo shadowInfo) {
    vec3 projCoord = fragLightSpacePos.xyz / fragLightSpacePos.w;

    if (projCoord.z < -1.0 || 1.0 < projCoord.z)
        return 0.0;

    vec2 texelSize = 1. / shadowMapTextureSize;
    vec2 corner1 = 0.5 * texelSize;
    vec2 corner2 = shadowMapImageSize / shadowMapTextureSize - corner1;    
    vec2 baseUV = img2texShadowMap(projCoord.xy * 0.5 + 0.5);
    // no shadows outside the shadowmap's frame
    if (any(lessThan(baseUV, corner1)) || any(greaterThan(baseUV, corner2)))
        return 0.0;

    float currentDepth = linearizeDepth(projCoord.z, shadowInfo.nearDist, shadowInfo.farDist) / shadowInfo.farDist;
    // currentDepth -= max(0.01 * (1.0 - dot(nrm, light)), 0.002);
    //currentDepth = invlerp(shadowInfo.nearDist, shadowInfo.farDist, currentDepth);
    currentDepth -= 0.003;

    float shadow = 0.0;
    float pcfDepth = 0.0;
    vec3 n = vec3(0.0);
    for (float x = -1.; x <= 1.; x += 1.) {
        for (float y = -1.; y <= 1.; y += 1.) {
            vec2 uv = baseUV + vec2(x, y) * texelSize;
            // we still need this clamp here because of PCF neighbor sampling
            uv = clamp(uv, corner1, corner2);
            
            pcfDepth = unpackRGBToDepth(texture2D(shadowMap, uv).rgb);
            //pcfDepth = texture2D(shadowMap, uv).r;
            n = texture2D(shadowMap, uv).rgb;
            shadow += currentDepth > pcfDepth ? 1.0 : 0.0;
        }
    }
    shadow /= 9.0;
    //gl_FragColor = vec4(n, 1.0);
    //return;
    // shadow = texture2D(shadowMap, img2texShadowMap(projCoord.xy)).r;
    return shadow;
}
#else
//#define PCF_3X3
float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
float calcShadow(vec4 fragLightSpacePos) {
    vec3 projCoord = fragLightSpacePos.xyz / fragLightSpacePos.w;

    if (projCoord.z < -1.0 || 1.0 < projCoord.z)
        return 0.0;

    vec2 texelSize = 1. / shadowMapTextureSize;
    vec2 corner1 = 0.5 * texelSize;
    vec2 corner2 = shadowMapImageSize / shadowMapTextureSize - corner1;
    projCoord.xy = projCoord.xy * 0.5 + 0.5;
    #ifdef PCF_3X3
        vec2 baseUV = img2texShadowMap(projCoord.xy);
    #else
        vec2 baseUV = (floor(projCoord.xy * shadowMapImageSize - 0.5) + 0.5) / shadowMapTextureSize;
    #endif
    // no shadows outside the shadowmap's frame
    if (any(lessThan(baseUV, corner1)) || any(greaterThan(baseUV, corner2)))
        return 0.0;

    float currentDepth = linearizeDepth(projCoord.z, shadowInfo.nearDist, shadowInfo.farDist) / shadowInfo.farDist;
    // currentDepth -= max(0.01 * (1.0 - dot(nrm, light)), 0.002);
    //currentDepth = invlerp(shadowInfo.nearDist, shadowInfo.farDist, currentDepth);
    currentDepth -= 0.003;

    #ifdef PCF_3X3
        #define IS_SHADOW_SIZE 9
        #define SHADOW_FILTER_UPPER_BOUND 1.0
        #define SHADOW_FILTER_SIZE 2
        #define NUM_PCF_RESULTS 4.0
    #else
        #define IS_SHADOW_SIZE 16
        #define SHADOW_FILTER_UPPER_BOUND 2.0
        #define SHADOW_FILTER_SIZE 3
        #define NUM_PCF_RESULTS 9.0
    #endif

    float isShadow[IS_SHADOW_SIZE];
    int i = 0;
    for (float y = -1.0; y <= SHADOW_FILTER_UPPER_BOUND; y += 1.0) {
        for (float x = -1.0; x <= SHADOW_FILTER_UPPER_BOUND; x += 1.0) {
            vec2 uv = baseUV + vec2(x, y) * texelSize;
            // we still need this clamp here because of PCF neighbor sampling
            uv = clamp(uv, corner1, corner2);
            
            float pcfDepth = unpackRGBToDepth(texture2D(shadowMap, uv).rgb);
            //pcfDepth = texture2D(shadowMap, uv).r;
            isShadow[i] = currentDepth > pcfDepth ? 1.0 : 0.0;
            i++;
        }
    }

    #ifdef PCF_3X3
        vec2 uvf = fract(projCoord.xy * shadowMapImageSize);
    #else
        vec2 uvf = fract(projCoord.xy * shadowMapImageSize - 0.5);
    #endif
    float shadow = 0.0;
    #define pcfBilinear(a, b, c, d) (mix(mix(isShadow[a], isShadow[b], uvf.x), mix(isShadow[c], isShadow[d], uvf.x), uvf.y))
    for (int i = 0; i < SHADOW_FILTER_SIZE; i++) {
        for (int j = 0; j < SHADOW_FILTER_SIZE; j++) {
            shadow += pcfBilinear(SHADOW_FILTER_SIZE*i+j, 1+SHADOW_FILTER_SIZE*i+j, SHADOW_FILTER_SIZE*(i+1)+j, 1+SHADOW_FILTER_SIZE*(i+1)+j);
        }
    }
    shadow /= NUM_PCF_RESULTS;
    //gl_FragColor = vec4(n, 1.0);
    //return;
    // shadow = texture2D(shadowMap, img2texShadowMap(projCoord.xy)).r;
    return shadow;
}
#endif
]],
    deps = {'packing', 'lights_frag_defs'}
}