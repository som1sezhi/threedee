local preprocess = require 'threedee.glsl.preprocess'

local vert = [[#version 120
#line 2 10021
#include <colorspaces>
#include <position_vert_defs>
#include <texcoord_vert_defs>
#include <color_vert_defs>

void main() {
    #include <position_vert>
    #include <texcoord_vert>
    #include <color_vert>
}
]]

local frag = [[#version 120
#line 2 20021
#include <utils>
#include <colorspaces>
#include <position_frag_defs>
#include <color_frag_defs>
#include <alpha_frag_defs>
#include <alphadiscard_frag_defs>
#include <texcoord_frag_defs>

void main() {
    #include <alpha_frag>
    #include <color_frag>
    #include <alphadiscard_frag>

    fragBaseColor = linear2Srgb(fragBaseColor);
    gl_FragColor = vec4(fragBaseColor, alpha);
}
]]

vert, frag = preprocess(vert, frag)

return {
    vert = vert, frag = frag
}