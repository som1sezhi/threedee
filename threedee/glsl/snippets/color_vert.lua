return {
    snippet = [[
    #ifdef USE_VERTEX_COLORS
        vColor = gl_Color;
        #ifdef VERTEX_COLORS_INTERPOLATE_LINEAR
            vColor.rgb = srgb2Linear(vColor.rgb);
        #endif
    #endif
]],
    deps = {'color_vert_defs', 'colorspaces'}
}