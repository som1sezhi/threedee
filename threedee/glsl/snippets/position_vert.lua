return {
    snippet = [[
    vec4 worldPos = modelMatrix * gl_Vertex;
	gl_Position = tdProjMatrix * tdViewMatrix * worldPos;
]],
    deps = {'position_vert_defs'}
}