local preprocess = require 'threedee.glsl.preprocess'

local vert = [[#version 120
#line 2 1002
#include <position_vert_defs>
#ifdef USE_ENV_MAP
    varying vec3 vDirection;
    uniform mat3 envMapRotation;
#endif

void main() {
    #include <position_vert>

    bool isOrthographic = tdProjMatrix[2][3] == 0.0;
    if (isOrthographic) {
        // force skybox to take up entire screen
        gl_Position = gl_Vertex;
    }
    gl_Position = gl_Position.xyww; // z = w/w = 1 (max depth)
    #ifdef USE_ENV_MAP
        if (isOrthographic) {
            vDirection = envMapRotation * -vec3(tdViewMatrix[0][2], tdViewMatrix[1][2], tdViewMatrix[2][2]);
        } else {
            vDirection = envMapRotation * gl_Vertex.xyz;
        }
    #endif
}
]]

local frag = [[#version 120
#line 2 2002
#include <utils>
#include <colorspaces>
#include <mapping>

uniform vec3 color;
uniform float intensity;
#ifdef USE_COLOR_MAP
    uniform sampler2D colorMap;
    uniform vec2 colorMapTextureSize;
    uniform vec2 colorMapImageSize;
    uniform vec2 displayResolution;
#endif
#ifdef USE_ENV_MAP
    varying vec3 vDirection;
    uniform sampler2D envMap;
#endif

void main() {
    vec3 col = color;
    #if defined(USE_COLOR_MAP)
        vec2 uv = gl_FragCoord.xy / displayResolution;
        uv = img2tex(uv, colorMapTextureSize, colorMapImageSize);
        col = srgb2Linear(texture2D(colorMap, uv).rgb);
    #elif defined(USE_ENV_MAP)
        // BUG: there's a visible seam when using
        // envmaps with mipmaps, due to UV discontinuity causing
        // mipmap derivatives to go wacky
        vec2 uv = getEnvMapUV(normalize(vDirection));
        col = srgb2Linear(texture2D(envMap, uv).rgb);
    #endif
    col *= intensity;
    col = linear2Srgb(col);
    
    gl_FragColor = vec4(col, 1.0);
}
]]

vert, frag = preprocess(vert, frag)

return {
    vert = vert, frag = frag
}