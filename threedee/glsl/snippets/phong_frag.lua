return {
    snippet = [[
    Material material;
    material.baseColor = fragBaseColor;
    material.specularColor = specular;
]],
    deps = {'phong_frag_defs', 'color_frag'},
    traits = {'defines_material'}
}
