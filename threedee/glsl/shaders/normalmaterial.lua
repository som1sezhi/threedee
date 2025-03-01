local preprocess = require 'threedee.glsl.preprocess'

local vert = [[#version 120
#line 2 10014
#include <position_vert_defs>
#include <posvaryings_vert_defs>
#include <normal_vert_defs>
#include <texcoord_vert_defs>
#include <color_vert_defs>

void main() {
	#include <normal_vert>
    #include <position_vert>
    #include <posvaryings_vert>
    #include <texcoord_vert>
    #include <color_vert>
}
]]

local frag = [[#version 120
#line 2 20014
#include <utils>
#include <position_frag_defs>
#include <posvaryings_frag_defs>
#include <normal_frag_defs>
#include <texcoord_frag_defs>
#include <alpha_frag_defs>
#include <alphamap_frag_defs>
#include <alphadiscard_frag_defs>

void main() {
    #include <normal_frag>
    #include <alpha_frag>
    #include <alphamap_frag>
    #include <alphadiscard_frag>
    gl_FragColor = vec4(normal * 0.5 + 0.5, alpha);
}
]]

vert, frag = preprocess(vert, frag)

return {
    vert = vert, frag = frag
}