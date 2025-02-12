local preprocess = require 'threedee.glsl.preprocess'

local vert = [[#version 120
#line 2 10014
#include <position_vert_defs>
#include <posvaryings_vert_defs>
#include <normal_vert_defs>
#include <texcoord_vert_defs>

void main() {
	#include <normal_vert>
    #include <position_vert>
    #include <posvaryings_vert>
    #include <texcoord_vert>
}
]]

local frag = [[#version 120
#line 2 20014
#include <posvaryings_frag_defs>
#include <normal_frag_defs>
#include <texcoord_frag_defs>
uniform sampler2D sampler0;

void main() {
    #include <normal_frag>
    float alpha = texture2D(sampler0, vTextureCoord).a;
    gl_FragColor = vec4(normal * 0.5 + 0.5, step(0.001, alpha));
}
]]

vert, frag = preprocess(vert, frag)

return {
    vert = vert, frag = frag
}