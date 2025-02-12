local preprocess = require 'threedee.glsl.preprocess'

local vert = [[#version 120
#line 2 10016
#include <position_vert_defs>
#include <posvaryings_vert_defs>
#include <normal_vert_defs>
#include <texcoord_vert_defs>
#include <color_vert_defs>

varying vec4 lightSpacePos;

uniform mat4 lightViewMatrix;
uniform mat4 lightProjMatrix;

void main() {
    #include <position_vert>
    #include <posvaryings_vert>
    #include <normal_vert>
    #include <texcoord_vert>
    #include <color_vert>

    lightSpacePos = lightProjMatrix * lightViewMatrix * worldPos;
}
]]

local frag = [[#version 120
#line 2 20016
#include <utils>
#include <packing>
#include <colorspaces>
#include <shadowmap_frag_defs>
#include <color_frag_defs>
#include <normal_frag_defs>
#include <posvaryings_frag_defs>
#include <texcoord_frag_defs>

varying vec4 lightSpacePos;

uniform vec3 diffuse;
uniform vec3 specular;
uniform vec3 emissive;
uniform float shininess;

uniform vec3 lightPos;

void main() {
    vec3 diffuseCol = diffuse;
    float alpha = 1.0;

    #include <color_frag>
    #include <normal_frag>
    #include <viewdir_frag>

    vec3 light = lightPos - vWorldPos;
    float lightDist = length(light);
    light /= lightDist;
    float diffuseFac = max(0., dot(normal, light));
    float specularFac = 0.;
    if (diffuseFac > 0.) {
        vec3 R = reflect(-light, normal);
        specularFac = pow(max(0., dot(R, viewDir)), shininess);
    }

    float attenuation = 1. / (1. + 0.000002 * lightDist * lightDist);

    if (doShadows) {
        float shadow = calcShadow(lightSpacePos);
        attenuation *= (1.0 - shadow);
    }

    const vec3 ambient = vec3(0.04);

    vec3 col = emissive;
    col += (attenuation * diffuseFac + ambient) * diffuseCol + specular * specularFac * attenuation;

    col = linear2SRGB(col);
    gl_FragColor = vec4(col, alpha);
}
]]

vert, frag = preprocess(vert, frag)

return {
    vert = vert, frag = frag
}