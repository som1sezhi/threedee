return {
    snippet = [[
#ifdef USE_VERTEX_COLORS
    varying vec4 vColor;
#endif

#ifdef TRANSPARENT
    uniform float opacity;
#endif
uniform bool useAlphaMap;
uniform bool useSampler0AlphaMap;
uniform bool useAlphaVertexColors;
uniform sampler2D alphaMap;
uniform sampler2D sampler0;
]],
    prevStageDeps = {'color_vert'}
}