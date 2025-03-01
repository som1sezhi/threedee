return {
    snippet = [[
#ifdef USE_VERTEX_COLORS
    varying vec4 vColor;
#endif

uniform bool useAlphaMap;
uniform bool useSampler0AlphaMap;
uniform bool useVertexColorAlpha;
uniform sampler2D alphaMap;
uniform sampler2D sampler0;
]],
    prevStageDeps = {'color_vert'}
}