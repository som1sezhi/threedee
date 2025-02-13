local preprocess = require 'threedee.glsl.preprocess'

local vert = [[#version 120
#line 2 10016
#include <position_vert_defs>
#include <posvaryings_vert_defs>
#include <normal_vert_defs>
#include <texcoord_vert_defs>
#include <color_vert_defs>
#include <lights_vert_defs>

void main() {
    #include <position_vert>
    #include <posvaryings_vert>
    #include <normal_vert>
    #include <texcoord_vert>
    #include <color_vert>
    #include <lights_vert>
}
]]

local frag = [[#version 120
#line 2 20016
#include <utils>
#include <packing>
#include <colorspaces>
#include <color_frag_defs>
#include <normal_frag_defs>
#include <posvaryings_frag_defs>
#include <texcoord_frag_defs>
#include <lights_frag_defs>
#include <phong_frag_defs>
#include <shadowmap_frag_defs>

uniform vec3 emissive;

void main() {
    #include <color_frag>
    #include <normal_frag>
    #include <phong_frag>
    #include <lights_frag>

    outgoingLight += emissive;
    outgoingLight = linear2Srgb(outgoingLight);
    gl_FragColor = vec4(outgoingLight, alpha);
}
]]

vert, frag = preprocess(vert, frag)

return {
    vert = vert, frag = frag
}