-- TODO: make double-sidedness toggleable
return {
    snippet = [[
    vec3 normal = normalize(vNormal) * vec3(1., -1., 1.);
    if (dot(normal, vViewVec) < 0.0)
        normal = -normal; // make surface double-sided
    #ifdef USE_NORMAL_MAP
        normal = perturbNormal(normal, vCameraRelativeWorldPos, vTextureCoord);
    #endif
]],
    deps = {'normal_frag_defs', 'posvaryings_frag_defs', 'texcoord_frag_defs'}
}
