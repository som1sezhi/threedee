return {
    snippet = [[
attribute vec4 TextureMatrixScale;

varying vec2 vTextureCoord;
uniform mat4 textureMatrix;

#ifdef USE_IMAGE_COORD
    varying vec2 vImageCoord;
    uniform vec2 textureSize;
    uniform vec2 imageSize;
#endif
]]
}