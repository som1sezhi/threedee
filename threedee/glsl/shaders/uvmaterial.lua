local preprocess = require 'threedee.glsl.preprocess'

local vert = [[#version 120
#line 2 1002122
#include <position_vert_defs>
#include <texcoord_vert_defs>

void main() {
    #include <position_vert>
    #include <texcoord_vert>
}
]]

local frag = [[#version 120
#line 2 2002122
#include <texcoord_frag_defs>

void main() {
    gl_FragColor = vec4(vTextureCoord, 0.0, 1.0);
}
]]

vert, frag = preprocess(vert, frag)

return {
    vert = vert, frag = frag
}