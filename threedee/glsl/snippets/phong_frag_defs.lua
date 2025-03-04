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

    vec3 halfwayDir = normalize(lightDir + viewDir);
    float specularFac = pow(max(0., dot(normal, halfwayDir)), shininess);

    return incomingLight * (diffuseFac * material.baseColor + specularFac * material.specularColor);
}
]],
    traits = {'defines_getOutgoingLight'}
}
