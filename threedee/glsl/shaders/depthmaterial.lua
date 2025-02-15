local preprocess = require 'threedee.glsl.preprocess'

local vert = [[#version 120
#line 2 1004
#include <position_vert_defs>
#include <texcoord_vert_defs>
varying float depth;

// uniform float nearDist;
uniform float farDist;

void main() {
    #include <position_vert>
    #include <texcoord_vert>

    // As it turns out, when NotITG draws an actor, it calls DISPLAY->SetZBias(),
	// which calls glDepthRange() with a range of size 0.95 (e.g. with a bias of 0,
	// the depth range will be [0.05, 1]). Thus we can't trust gl_FragCoord.z to
	// hold the "true" depth value of the fragment, so we must calculate it ourselves.
    depth = -viewPos.z / farDist;
    // depth = invlerp(nearDist, farDist, depth);
}
]]

local frag = [[#version 120
#line 2 2004
#include <utils>
#include <packing>
#include <texcoord_frag_defs>
varying float depth;

uniform sampler2D sampler0;

void main() {
    float alpha = texture2D(sampler0, vTextureCoord).a;
    gl_FragColor = vec4(packDepthToRGB(depth), step(0.001, alpha));
}
]]

vert, frag = preprocess(vert, frag)

return {
    vert = vert, frag = frag
}