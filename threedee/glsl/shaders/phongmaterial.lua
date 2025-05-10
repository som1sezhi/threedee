local preprocess = require 'threedee.glsl.preprocess'

local vert = [[#version 120
#line 2 10016
#include <colorspaces>
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
#include <mapping>
#include <position_frag_defs>
#include <color_frag_defs>
#include <alpha_frag_defs>
#include <alphadiscard_frag_defs>
#include <normal_frag_defs>
#include <posvaryings_frag_defs>
#include <texcoord_frag_defs>
#include <lights_frag_defs>
#include <phong_frag_defs>
#include <shadowmap_frag_defs>
#include <envmap_frag_defs>
#include <dithering_frag_defs>

uniform vec3 emissive;
#ifdef USE_EMISSIVE_MAP
    uniform sampler2D emissiveMap;
#endif

void main() {
    #include <alpha_frag>
    #include <color_frag>
    #include <normal_frag>
    #include <alphadiscard_frag>
    #include <phong_frag>
    #include <lights_frag>
    #include <envmap_frag>

    #ifdef USE_EMISSIVE_MAP
        outgoingLight += emissive * texture2D(emissiveMap, vTextureCoord).rgb;
    #else
        outgoingLight += emissive;
    #endif
    outgoingLight = linear2Srgb(outgoingLight);
    gl_FragColor = vec4(outgoingLight, alpha);
    #include <dithering_frag>
}
]]

vert, frag = preprocess(vert, frag)

return {
    vert = vert, frag = frag
}