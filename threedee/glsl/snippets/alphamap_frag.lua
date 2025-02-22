return {
    snippet = [[
    float alpha = 1.0;
    #ifdef USE_VERTEX_COLORS
        if (useAlphaVertexColors)
            alpha = vColor.a;
    #endif
    if (useAlphaMap) {
        if (useSampler0AlphaMap)
            alpha *= texture2D(sampler0, vTextureCoord).a;
        else
            alpha *= texture2D(alphaMap, vTextureCoord).a;
    }
]],
    deps = {'alphamap_frag_defs', 'texcoord_frag_defs'}
}