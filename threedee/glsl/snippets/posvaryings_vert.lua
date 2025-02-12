return {
    snippet = [[
    vWorldPos = worldPos.xyz;
    vViewVec = cameraPos - vWorldPos;
]],
    deps = {'posvaryings_vert_defs'}
}