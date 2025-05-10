return {
    snippet = [[
    #ifdef DITHERING
        gl_FragColor.rgb = dithering(gl_FragColor.rgb);
    #endif
]],
    deps = {
        'dithering_frag_defs'
    }
}
