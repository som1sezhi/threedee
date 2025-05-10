-- thanks, 0b5vr!
return {
    snippet = [[
#ifdef DITHERING
    // Ref: https://www.shadertoy.com/view/MslGR8
    // Ref: https://github.com/mrdoob/three.js/blob/r176/src/renderers/shaders/ShaderChunk/dithering_pars_fragment.glsl.js
    vec3 dithering(vec3 color) {
        float dice = hash2D(gl_FragCoord.xy);
        vec3 shiftRGB = vec3(0.5, -0.5, 0.5) / 255.0;
        return color + mix(shiftRGB, -shiftRGB, dice);
    }
#endif
]],
    deps = {
        'utils'
    }
}
