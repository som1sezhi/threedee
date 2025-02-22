return {
    snippet = [[
#ifdef USE_VERTEX_COLORS
    varying vec4 vColor;
#endif

uniform vec3 color;

#ifdef USE_COLOR_MAP
    #ifdef USE_COLOR_MAP_SAMPLER0
        uniform sampler2D sampler0;
        #define colorMap sampler0
    #else
        uniform sampler2D colorMap;
    #endif
#endif
]],
    prevStageDeps = {'color_vert'}
}