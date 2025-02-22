return {
    snippet = [[
    vec4 worldPos = modelMatrix * gl_Vertex;
    vec4 viewPos = tdViewMatrix * worldPos;
	gl_Position = tdProjMatrix * viewPos;
    #ifdef USE_ALPHA_HASH
        vPosition = gl_Vertex.xyz;
    #endif
]],
    deps = {'position_vert_defs'}
}