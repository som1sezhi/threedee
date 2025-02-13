return {
    snippet = [[
#ifdef USE_VERTEX_COLORS
    varying vec4 vColor;
#endif

uniform vec3 color;

#ifdef USE_DIFFUSE_MAP
    #ifdef USE_DIFFUSE_MAP_SAMPLER0
        uniform sampler2D sampler0;
        #define diffuseMap sampler0
    #else
        uniform sampler2D diffuseMap;
    #endif
#endif
]],
    prevStageDeps = {'color_vert'}
}