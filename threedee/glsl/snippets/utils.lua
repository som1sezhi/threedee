return {
    snippet = [[
float modf_(float f, out float i) {
    i = floor(f);
    return fract(f);
}

float invlerp(float a, float b, float v) {
    return (v - a) / (b - a);
}
]]
}