return {
    snippet = [[
varying vec3 vNormal;

#ifdef USE_NORMAL_MAP
    varying vec3 vCameraRelativeWorldPos;
    uniform sampler2D normalMap;

    // from "Followup: Normal Mapping Without Precomputed Tangents"
    // http://www.thetenthplanet.de/archives/1180

    mat3 cotangentFrame(vec3 N, vec3 p, vec2 uv) {
        // get edge vectors of the pixel triangle
        vec3 dp1 = dFdx(p);
        vec3 dp2 = dFdy(p);
        vec2 duv1 = dFdx(uv);
        vec2 duv2 = dFdy(uv);
        // solve the linear system
        vec3 dp2perp = cross(dp2, N);
        vec3 dp1perp = cross(N, dp1);
        vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
        vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;
        // construct a scale-invariant frame
        float invmax = inversesqrt(max(dot(T,T), dot(B,B)));
        // invert T to make it work with NotITG's coord system
        return mat3(-T * invmax, B * invmax, N);
    }

    vec3 perturbNormal(vec3 N, vec3 V, vec2 texCoord) {
        vec3 map = texture2D(normalMap, (texCoord)).xyz;
        map = map * 255.0/127.0 - 128.0/127.0; // map 128 -> 0 (exact middle)
        map.y *= -1.; // green -> up in the normal map
        mat3 TBN = cotangentFrame(N, -V, texCoord);
        return normalize(TBN * map);
    }
#endif
]],
    prevStageDeps = {'normal_vert'}
}
