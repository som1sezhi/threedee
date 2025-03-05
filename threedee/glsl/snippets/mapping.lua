--[[
sphere mapping adapted from https://github.com/hughsk/matcap/blob/master/matcap.glsl
Copyright (c) 2014 Hugh Kennedy

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

return {
    snippet = [[
vec2 getSphereMapUV(vec3 dir) {
    // NOTE: technically dir.y should be flipped here to transform from NotITG's
    // Y-down space to OpenGL's Y-up space, but NotITG also has flipped texture coords
    // for whatever reason ((0, 0) is at top=left instead of the usual bottom-left for OpenGL),
    // so the flips cancel out in the end
    float m = 2.8284271247461903 * sqrt(dir.z + 1.0);
    return dir.xy / m + 0.5;
}

const vec2 invAtan = vec2(0.5 / PI, 1.0 / PI);
vec2 getEquirectMapUV(vec3 dir) {
    // same NOTE applies here too
    vec2 uv = vec2(atan(dir.z, dir.x), asin(dir.y));
    uv *= invAtan;
    uv += 0.5;
    return uv;
}

#ifdef USE_ENV_MAP
    #if defined(ENV_MAP_MAPPING_SPHERE)
        #define getEnvMapUV getSphereMapUV
    #elif defined(ENV_MAP_MAPPING_EQUIRECT)
        #define getEnvMapUV getEquirectMapUV
    #else
        #error "unknown envMap mapping"
    #endif
#endif
]],
    deps = {'utils'}
}
