return {
    snippet = [[
    vec3 fragBaseColor = color;
    float alpha = 1.0;
    #ifdef USE_VERTEX_COLORS
        fragBaseColor *= srgb2Linear(vColor.rgb);
        alpha = vColor.a; // same as multiplying by 1
    #endif
    #ifdef USE_COLOR_MAP
        vec4 colorMapSample = texture2D(colorMap, vTextureCoord);
        fragBaseColor *= srgb2Linear(colorMapSample.rgb);
        alpha *= colorMapSample.a;
    #endif
]],
    deps = {'color_frag_defs', 'colorspaces', 'texcoord_frag_defs'}
}