return {
    snippet = [[
    vec4 worldPos = modelMatrix * gl_Vertex;
    vec4 viewPos = tdViewMatrix * worldPos;
	gl_Position = tdProjMatrix * viewPos;
]],
    deps = {'position_vert_defs'}
}