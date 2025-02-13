return {
    snippet = [[
uniform vec3 specular;
uniform float shininess;

struct Material {
    vec3 baseColor;
    vec3 specularColor;
};

vec3 getOutgoingLight(vec3 incomingLight, vec3 lightDir, vec3 viewDir, vec3 normal, const Material material) {
    float diffuseFac = max(0., dot(normal, lightDir));
    float specularFac = 0.;
    if (diffuseFac > 0.) {
        vec3 R = reflect(-lightDir, normal);
        specularFac = pow(max(0., dot(R, viewDir)), shininess);
    }
    return incomingLight * (diffuseFac * material.baseColor + specularFac * material.specularColor);
}
]],
    traits = {'defines_getOutgoingLight'}
}
