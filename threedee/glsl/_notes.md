## Varyings

```glsl
// world-space position
varying vec3 vWorldPos;

// camera position - fragment position (world space) if camera is perspective
// negative of camera view direction (world space, unnormalized) if camera is orthographic
varying vec3 vViewVec;

// world-space normal (not normalized)
varying vec3 vNormal;

// like NotITG's textureCoord
varying vec2 vTextureCoord;

// like NotITG's imageCoord
varying vec2 vImageCoord;

// like NotITG's color
varying vec4 vColor;
```