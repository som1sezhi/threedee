return {
    snippet = [[
    Material material;
    material.baseColor = fragBaseColor;
    material.specularColor = specular;
    #ifdef USE_SPECULAR_MAP
        #define SPECULAR_MAP_SAMPLE_DEFINED // for use in <envmap_frag> if needed
        vec3 specularMapSample = texture2D(specularMap, vTextureCoord).rgb;
        #ifdef SPECULAR_MAP_COLORSPACE_SRGB
            specularMapSample = srgb2Linear(specularMapSample);
        #endif
        material.specularColor *= specularMapSample;
    #endif
]],
    deps = {'phong_frag_defs', 'color_frag', 'texcoord_frag_defs', 'colorspaces'},
    traits = {'defines_material'}
}
