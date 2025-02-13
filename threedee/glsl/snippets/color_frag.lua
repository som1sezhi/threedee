return {
    snippet = [[
    vec3 fragBaseColor = color;
    float alpha = 1.0;
    #ifdef USE_VERTEX_COLORS
        fragBaseColor *= srgb2Linear(vColor.rgb);
        alpha *= vColor.a;
    #endif
    #ifdef USE_DIFFUSE_MAP
        vec4 diffuseMapSample = texture2D(diffuseMap, vTextureCoord);
        fragBaseColor *= pow(diffuseMapSample.rgb, vec3(2.2));
        alpha *= diffuseMapSample.a;
    #endif
]],
    deps = {'color_frag_defs', 'colorspaces', 'texcoord_frag_defs'}
}