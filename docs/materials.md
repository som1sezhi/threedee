# Built-in Materials

Remember that all these properties are in addition to the properties provided by the base class.

## `DepthMaterial`

A material used to visualize the depth of the scene, or to encode depth values
as colors. This material is used internally to draw shadow maps.

### Properties

#### `DepthMaterial.alphaHash: boolean`
Enable [hashed alpha testing](https://casual-effects.com/research/Wyman2017Hashed/index.html). If alpha is lower than a random threshold, the pixel is discarded. This allows for the appearance of gradations of transparency even if `.transparent` is false, and also allows for overlapping transparent geometry looking correct without having to sort them by distance, though the result can end up very noisy.
- Default value: `false`
- Updatable during runtime: ❌

#### `DepthMaterial.alphaMap: 'sampler0'|RageTexture|false`
The alpha channel of this texture is used to modulate the material's alpha. If set to `'sampler0'`, use the actor's default texture.
- Default value: `false`
- Updatable during runtime: ⚠️

#### `DepthMaterial.alphaTest: number`
Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false.
- Default value: `0.001`
- Updatable during runtime: ✅

#### `DepthMaterial.dithering: boolean`
Whether to perform dithering. This can reduce the appearance of banding artifacts at the cost of introducing some noise.
- Default value: `false`
- Updatable during runtime: ❌

#### `DepthMaterial.opacity: number`
The base alpha.
- Default value: `1` (fully opaque)
- Updatable during runtime: ✅

#### `DepthMaterial.packingFormat: 'none'|'rg'|'rgb'`
How to pack the depth value into the color channels. `'none'` performs no packing, `'rg'` uses the red and green channels, and `'rgb'` uses the red, green, and blue channels.
- Default value: `'none'`
- Updatable during runtime: ❌

#### `DepthMaterial.transparent: boolean`
Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded.
- Default value: `false`
- Updatable during runtime: ❌

#### `DepthMaterial.useVertexColorAlpha: boolean`
Whether to use the actor's vertex color alpha to modulate the alpha of the material.
- Default value: `false`
- Updatable during runtime: ❌


## `MatcapMaterial`

A material that uses a matcap texture to give an appearance of lighting/shading.

### Properties

#### `MatcapMaterial.alphaHash: boolean`
Enable [hashed alpha testing](https://casual-effects.com/research/Wyman2017Hashed/index.html). If alpha is lower than a random threshold, the pixel is discarded. This allows for the appearance of gradations of transparency even if `.transparent` is false, and also allows for overlapping transparent geometry looking correct without having to sort them by distance, though the result can end up very noisy.
- Default value: `false`
- Updatable during runtime: ❌

#### `MatcapMaterial.alphaTest: number`
Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false.
- Default value: `0.001`
- Updatable during runtime: ✅

#### `MatcapMaterial.color: Vec3`
Base color.
- Default value: `(1, 1, 1)` (white)
- Updatable during runtime: ✅

#### `MatcapMaterial.colorMap: 'sampler0'|RageTexture|false`
Base color texture. An alpha channel may be included. If set to `'sampler0'`, use the actor's default texture.
- Default value: `false`
- Updatable during runtime: ⚠️

#### `MatcapMaterial.dithering: boolean`
Whether to perform dithering. This can reduce the appearance of banding artifacts at the cost of introducing some noise.
- Default value: `false`
- Updatable during runtime: ❌

#### `MatcapMaterial.matcap: RageTexture|false`
The matcap texture.
- Default value: `false`
- Updatable during runtime: ⚠️

#### `MatcapMaterial.normalMap: RageTexture|false`
The normal map.
- Default value: `false`
- Updatable during runtime: ⚠️

#### `MatcapMaterial.opacity: number`
The base alpha.
- Default value: `1` (fully opaque)
- Updatable during runtime: ✅

#### `MatcapMaterial.transparent: boolean`
Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded.
- Default value: `false`
- Updatable during runtime: ❌

#### `MatcapMaterial.useVertexColors: boolean`
Whether to use the actor's vertex colors to color the material. Among other things, this allows you to color actors individually using `:diffuse()`.
- Default value: `false`
- Updatable during runtime: ❌

#### `MatcapMaterial.vertexColorInterpolation: 'linear'|'srgb'`
If using vertex colors, this defines whether to interpolate vertex colors in linear RGB or sRGB space. Linear RGB is more "correct" and can look better in certain cases, while sRGB gives closer results to what you might get using regular NotITG methods like `:diffusetopedge()` and such. Note that the vertex color values themselves are always specified in sRGB space.
- Default value: `'linear'`
- Updatable during runtime: ❌


## `NormalMaterial`

A material that visualizes normal vectors as RGB colors.

### Properties

#### `NormalMaterial.alphaHash: boolean`
Enable [hashed alpha testing](https://casual-effects.com/research/Wyman2017Hashed/index.html). If alpha is lower than a random threshold, the pixel is discarded. This allows for the appearance of gradations of transparency even if `.transparent` is false, and also allows for overlapping transparent geometry looking correct without having to sort them by distance, though the result can end up very noisy.
- Default value: `false`
- Updatable during runtime: ❌

#### `NormalMaterial.alphaMap: 'sampler0'|RageTexture|false`
The alpha channel of this texture is used to modulate the material's alpha. If set to `'sampler0'`, use the actor's default texture.
- Default value: `false`
- Updatable during runtime: ⚠️

#### `NormalMaterial.alphaTest: number`
Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false.
- Default value: `0.001`
- Updatable during runtime: ✅

#### `NormalMaterial.dithering: boolean`
Whether to perform dithering. This can reduce the appearance of banding artifacts at the cost of introducing some noise.
- Default value: `false`
- Updatable during runtime: ❌

#### `NormalMaterial.normalMap: RageTexture|false`
The normal map.
- Default value: `false`
- Updatable during runtime: ⚠️

#### `NormalMaterial.opacity: number`
The base alpha.
- Default value: `1` (fully opaque)
- Updatable during runtime: ✅

#### `NormalMaterial.transparent: boolean`
Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded.
- Default value: `false`
- Updatable during runtime: ❌

#### `NormalMaterial.useVertexColorAlpha: boolean`
Whether to use the actor's vertex color alpha to modulate the alpha of the material.
- Default value: `false`
- Updatable during runtime: ❌


## `PhongMaterial`

A material using the Blinn-Phong shading model.

### Properties

#### `PhongMaterial.alphaHash: boolean`
Enable [hashed alpha testing](https://casual-effects.com/research/Wyman2017Hashed/index.html). If alpha is lower than a random threshold, the pixel is discarded. This allows for the appearance of gradations of transparency even if `.transparent` is false, and also allows for overlapping transparent geometry looking correct without having to sort them by distance, though the result can end up very noisy.
- Default value: `false`
- Updatable during runtime: ❌

#### `PhongMaterial.alphaTest: number`
Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false.
- Default value: `0.001`
- Updatable during runtime: ✅

#### `PhongMaterial.color: Vec3`
Base color.
- Default value: `(1, 1, 1)` (white)
- Updatable during runtime: ✅

#### `PhongMaterial.colorMap: 'sampler0'|RageTexture|false`
Base color texture. An alpha channel may be included. If set to `'sampler0'`, use the actor's default texture.
- Default value: `false`
- Updatable during runtime: ⚠️

#### `PhongMaterial.dithering: boolean`
Whether to perform dithering. This can reduce the appearance of banding artifacts at the cost of introducing some noise.
- Default value: `false`
- Updatable during runtime: ❌

#### `PhongMaterial.emissive: Vec3`
Emissive color.
- Default value: `(0, 0, 0)` (black)
- Updatable during runtime: ✅

#### `PhongMaterial.emissiveMap: RageTexture|false`
Emissive map. Be sure to set `.emissive` to a non-black value to see any effect.
- Default value: `false`
- Updatable during runtime: ⚠️

#### `PhongMaterial.envMap: EnvMap|false`
The environment map.
- Default value: `false`
- Updatable during runtime: ⚠️

#### `PhongMaterial.envMapCombine: 'add'|'mix'|'multiply'`
The math operation used to blend the environment map with the material.
- Default value: `'multiply'`
- Updatable during runtime: ❌

#### `PhongMaterial.envMapRotation: Mat3`
The rotation of the environment map.
- Default value: identity matrix
- Updatable during runtime: ✅

#### `PhongMaterial.envMapStrength: number`
How much the environment map affects the color of the material.
- Default value: `1` (full strength)
- Updatable during runtime: ✅

#### `PhongMaterial.envMapType: 'reflection'|'refraction'`
Whether to use `.envMap` as a reflection or refraction map.
- Default value: `'reflection'`
- Updatable during runtime: ❌

#### `PhongMaterial.normalMap: RageTexture|false`
The normal map.
- Default value: `false`
- Updatable during runtime: ⚠️

#### `PhongMaterial.opacity: number`
The base alpha.
- Default value: `1` (fully opaque)
- Updatable during runtime: ✅

#### `PhongMaterial.refractionRatio: number`
The index of refraction (IOR) of air divided by the IOR of the material. Only has an effect if `.envMapType = 'refraction'`.
- Default value: `0.98`
- Updatable during runtime: ✅

#### `PhongMaterial.shininess: number`
The sharpness of the specular highlight.
- Default value: `32`
- Updatable during runtime: ✅

#### `PhongMaterial.specular: Vec3`
Specular color.
- Default value: `(1, 1, 1)` (white)
- Updatable during runtime: ✅

#### `PhongMaterial.specularMap: RageTexture|false`
Specular map. Affects both the specular color and the environment map.
- Default value: `false`
- Updatable during runtime: ⚠️

#### `PhongMaterial.specularMapColorSpace: 'linear'|'srgb'`
Whether to interpret the specular map data as linear or sRGB. If the specular map is grayscale, this should probably be `'linear'`; if it is colored, this should probably be `'srgb'`.
- Default value: `'linear'`
- Updatable during runtime: ❌

#### `PhongMaterial.transparent: boolean`
Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded.
- Default value: `false`
- Updatable during runtime: ❌

#### `PhongMaterial.useVertexColors: boolean`
Whether to use the actor's vertex colors to color the material. Among other things, this allows you to color actors individually using `:diffuse()`.
- Default value: `false`
- Updatable during runtime: ❌

#### `PhongMaterial.vertexColorInterpolation: 'linear'|'srgb'`
If using vertex colors, this defines whether to interpolate vertex colors in linear RGB or sRGB space. Linear RGB is more "correct" and can look better in certain cases, while sRGB gives closer results to what you might get using regular NotITG methods like `:diffusetopedge()` and such. Note that the vertex color values themselves are always specified in sRGB space.
- Default value: `'linear'`
- Updatable during runtime: ❌


## `UVMaterial`

A debug material that visualizes the UV coordinates on an object using red and green values.

### Properties

#### `UVMaterial.dithering: boolean`
Whether to perform dithering. This can reduce the appearance of banding artifacts at the cost of introducing some noise.
- Default value: `false`
- Updatable during runtime: ❌


## `UnlitMaterial`

A material that only shows the base color and does not respond to lighting.

### Properties

#### `UnlitMaterial.alphaHash: boolean`
Enable [hashed alpha testing](https://casual-effects.com/research/Wyman2017Hashed/index.html). If alpha is lower than a random threshold, the pixel is discarded. This allows for the appearance of gradations of transparency even if `.transparent` is false, and also allows for overlapping transparent geometry looking correct without having to sort them by distance, though the result can end up very noisy.
- Default value: `false`
- Updatable during runtime: ❌

#### `UnlitMaterial.alphaTest: number`
Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false.
- Default value: `0.001`
- Updatable during runtime: ✅

#### `UnlitMaterial.color: Vec3`
Base color.
- Default value: `(1, 1, 1)` (white)
- Updatable during runtime: ✅

#### `UnlitMaterial.colorMap: 'sampler0'|RageTexture|false`
Base color texture. An alpha channel may be included. If set to `'sampler0'`, use the actor's default texture.
- Default value: `false`
- Updatable during runtime: ⚠️

#### `UnlitMaterial.dithering: boolean`
Whether to perform dithering. This can reduce the appearance of banding artifacts at the cost of introducing some noise.
- Default value: `false`
- Updatable during runtime: ❌

#### `UnlitMaterial.opacity: number`
The base alpha.
- Default value: `1` (fully opaque)
- Updatable during runtime: ✅

#### `UnlitMaterial.transparent: boolean`
Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded.
- Default value: `false`
- Updatable during runtime: ❌

#### `UnlitMaterial.useVertexColors: boolean`
Whether to use the actor's vertex colors to color the material. Among other things, this allows you to color actors individually using `:diffuse()`.
- Default value: `false`
- Updatable during runtime: ❌

#### `UnlitMaterial.vertexColorInterpolation: 'linear'|'srgb'`
If using vertex colors, this defines whether to interpolate vertex colors in linear RGB or sRGB space. Linear RGB is more "correct" and can look better in certain cases, while sRGB gives closer results to what you might get using regular NotITG methods like `:diffusetopedge()` and such. Note that the vertex color values themselves are always specified in sRGB space.
- Default value: `'linear'`
- Updatable during runtime: ❌


