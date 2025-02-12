return {
    snippet = [[
    #ifdef USE_VERTEX_COLORS
        vColor = gl_Color;
    #endif
]],
    deps = {'color_vert_defs'}
}