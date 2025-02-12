-- note: 
-- gl_NormalMatrix = transpose(inverse(mat3(gl_ModelViewMatrix)))
-- but gl_ModelViewMatrix should be equivalent to just the model matrix
-- for our purposes, so this should transform the normal to our world space
return {
    snippet = [[
    vNormal = gl_NormalMatrix * gl_Normal * vec3(1.0, -1.0, 1.0);
]],
    deps = {'normal_vert_defs'}
}