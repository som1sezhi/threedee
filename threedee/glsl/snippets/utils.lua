return {
    snippet = [[
#define PI 3.1415926538

float modf_(float f, out float i) {
    i = floor(f);
    return fract(f);
}

float invlerp(float a, float b, float v) {
    return (v - a) / (b - a);
}

vec2 img2tex(vec2 uv, vec2 textureSize, vec2 imageSize) {
    return uv / textureSize * imageSize;
}

// http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
// i'm not sure if the issues discussed apply to desktop opengl, but may as well
float hash2D(vec2 coord) {
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt = dot(coord.xy, vec2(a, b));
    float sn = mod(dt, 3.14);
    return fract(sin(sn) * c);
}

float hash3D(vec3 coord) {
    return hash2D( vec2( hash2D( coord.xy ), coord.z ) );
}
]]
}