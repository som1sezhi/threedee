local preprocess = require 'threedee.glsl.preprocess'

local vert = [[#version 120
#line 2 1004
// for vertex color alpha
#define USE_VERTEX_COLORS

#include <utils>
#include <colorspaces>
#include <position_vert_defs>
#include <texcoord_vert_defs>
#include <color_vert_defs>
varying float depth;

uniform float nearDist;
uniform float farDist;

void main() {
    #include <position_vert>
    #include <texcoord_vert>
    #include <color_vert>

    // As it turns out, when NotITG draws an actor, it calls DISPLAY->SetZBias(),
	// which calls glDepthRange() with a range of size 0.95 (e.g. with a bias of 0,
	// the depth range will be [0.05, 1]). Thus we can't trust gl_FragCoord.z to
	// hold the "true" depth value of the fragment, so we must calculate it ourselves.
    depth = invlerp(nearDist, farDist, -viewPos.z);
}
]]

local frag = [[#version 120
#line 2 2004
#define USE_VERTEX_COLORS
#include <utils>
#include <packing>
#include <position_frag_defs>
#include <texcoord_frag_defs>
#include <alphamap_frag_defs>
#include <alpha_frag_defs>
#include <alphadiscard_frag_defs>
#include <dithering_frag_defs>
varying float depth;

void main() {
    #include <alpha_frag>
    #include <alphamap_frag>
    #include <alphadiscard_frag>
    #if defined(PACK_FORMAT_RGB)
        gl_FragColor = vec4(packDepthToRGB(depth), alpha);
    #elif defined(PACK_FORMAT_RG)
        gl_FragColor = vec4(packDepthToRG(depth), 0.0, alpha);
    #else
        gl_FragColor = vec4(vec3(depth), alpha);
    #endif
    #include <dithering_frag>
}
]]

vert, frag = preprocess(vert, frag)

return {
    vert = vert, frag = frag
}