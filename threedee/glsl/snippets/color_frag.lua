return {
    snippet = [[
    vec3 fragBaseColor = color;
    #ifdef USE_VERTEX_COLORS
        #ifdef VERTEX_COLORS_INTERPOLATE_LINEAR
            fragBaseColor *= vColor.rgb;
        #else
            fragBaseColor *= srgb2Linear(vColor.rgb);
        #endif
        alpha *= vColor.a;
    #endif
    #ifdef USE_COLOR_MAP
        vec4 colorMapSample = texture2D(colorMap, vTextureCoord);
        fragBaseColor *= srgb2Linear(colorMapSample.rgb);
        alpha *= colorMapSample.a;
    #endif
]],
    deps = {'color_frag_defs', 'colorspaces', 'texcoord_frag_defs', 'alpha_frag'}
}