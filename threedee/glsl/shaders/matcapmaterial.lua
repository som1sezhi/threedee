local preprocess = require 'threedee.glsl.preprocess'

local vert = [[#version 120
#line 2 10013
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
#line 2 20013
#include <utils>
#include <mapping>
#include <colorspaces>
#include <position_frag_defs>
#include <posvaryings_frag_defs>
#include <normal_frag_defs>
#include <texcoord_frag_defs>
#include <color_frag_defs>
#include <alpha_frag_defs>
#include <alphadiscard_frag_defs>

#ifdef USE_MATCAP
    uniform sampler2D matcap;
    uniform mat4 tdViewMatrix;
#endif

void main() {
    #include <normal_frag>
    #include <alpha_frag>
    #include <color_frag>
    #include <alphadiscard_frag>

    #ifdef USE_MATCAP
        vec3 sampleDir = reflect(-normalize(vViewVec), normal);
        // TODO: figure out best way to move this to vertex shader
        sampleDir = mat3(tdViewMatrix) * sampleDir;
        fragBaseColor *= srgb2Linear(texture2D(matcap, getSphereMapUV(sampleDir)).rgb);
    #endif

    fragBaseColor = linear2Srgb(fragBaseColor);
    gl_FragColor = vec4(fragBaseColor, alpha);
}
]]

vert, frag = preprocess(vert, frag)

return {
    vert = vert, frag = frag
}