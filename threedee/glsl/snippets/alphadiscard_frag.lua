-- NOTE: this should probably be placed after any snippet that uses
-- derivatives, since the derivative values may get messed up by
-- the absence of neighboring fragments discarded by the alpha test

return {
    snippet = [[
    if (alpha < alphaTest)
        discard;
    #ifdef USE_ALPHA_HASH
        if (alpha < getAlphaHashThreshold(vPosition))
            discard;
    #endif
    #ifndef TRANSPARENT
        alpha = 1.0;
    #endif
]],
    deps = {'alphadiscard_frag_defs', 'position_frag_defs', 'alpha_frag'}
}