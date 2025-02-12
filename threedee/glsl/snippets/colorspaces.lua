return {
    snippet = [[
vec3 srgb2Linear(vec3 col) {
    return pow(col, vec3(2.2));
}

vec3 linear2SRGB(vec3 col) {
    return pow(col, vec3(.4545));
}
]]
}