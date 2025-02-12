return {
    snippet = [[
varying vec2 vTextureCoord;
#ifdef USE_IMAGE_COORD
    varying vec2 vImageCoord;
#endif
]],
    prevStageDeps = {'texcoord_vert'}
}