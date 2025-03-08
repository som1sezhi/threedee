return {
    snippet = [[
    vWorldPos = worldPos.xyz;
    bool isOrthographic = tdProjMatrix[2][3] == 0.0;
    if (isOrthographic) {
        vViewVec = vec3(tdViewMatrix[0][2], tdViewMatrix[1][2], tdViewMatrix[2][2]);
    } else {
        vViewVec = cameraPos - vWorldPos;
    }
]],
    deps = {'posvaryings_vert_defs', 'position_vert'}
}