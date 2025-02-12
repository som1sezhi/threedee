return {
    snippet = [[
    // gl_TexCoord[0] = (textureMatrix * gl_MultiTexCoord0 * TextureMatrixScale) + (gl_MultiTexCoord0 * (vec4(1.0)-TextureMatrixScale));
    vTextureCoord = ((textureMatrix * gl_MultiTexCoord0 * TextureMatrixScale) + (gl_MultiTexCoord0 * (vec4(1.0)-TextureMatrixScale))).xy;
    #ifdef USE_IMAGE_COORD
	    vImageCoord = vTextureCoord * textureSize / imageSize;
    #endif
]],
    deps = {'texcoord_vert_defs'}
}