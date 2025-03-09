# Built-in Materials

Note that all these properties are in addition to the properties provided by the base class.

Emoji meanings:
- ✅: This property is allowed to be modified after scene finalization/during "runtime", via the material's `:update()` method.
- ⚠️: This property may only be modified during runtime to a value with the *same type* as the previous value. For example, a `.colorMap` property that was set to a `RageTexture` can only be changed to another `RageTexture`. An `.envMap` property set to an `EnvMap` may only be set to another `EnvMap` with the *same properties* (mapping, color format, etc.), besides perhaps the texture itself. A property set to `false` or `'sampler0'` should not be modified during runtime at all.
- ❌: This property should not be modified at runtime.

## DepthMaterial

A material used to visualize the depth of the scene, or to encode depth values
as colors. This material is used internally to draw shadow maps.

### Properties

#### `.alphaHash: boolean`
Enable hashed alpha testing. If alpha is lower than a random threshold, the pixel is discarded. This allows for gradations of transparency even while `.transparent` is false, but it looks very noisy.
- Default value: `false`
- Updatable during runtime?: ❌

#### `.alphaMap: 'sampler0'|RageTexture|false`
The alpha channel of this texture is used to modulate the material's alpha. If set to `'sampler0'`, use the actor's default texture.
- Default value: `false`
- Updatable during runtime?: ⚠️

#### `.alphaTest: number`
Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false.
- Default value: `0.001`
- Updatable during runtime?: ✅

#### `.opacity: number`
The base alpha.
- Default value: `1`
- Updatable during runtime?: ✅

#### `.packingFormat: 'none'|'rg'|'rgb'`
How to pack the depth value into the color channels. `'none'` performs no packing, `'rg'` uses the red and green channels, and `'rgb'` uses the red, green, and blue channels.
- Default value: `'none'`
- Updatable during runtime?: ❌

#### `.transparent: boolean`
Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded.
- Default value: `false`
- Updatable during runtime?: ❌

#### `.useVertexColorAlpha: boolean`
Whether to use the actor's vertex color alpha to modulate the alpha of the material.
- Default value: `false`
- Updatable during runtime?: ❌


## MatcapMaterial

A material that uses a matcap texture to give an appearance of lighting/shading.

### Properties

#### `.alphaHash: boolean`
Enable hashed alpha testing. If alpha is lower than a random threshold, the pixel is discarded. This allows for gradations of transparency even while `.transparent` is false, but it looks very noisy.
- Default value: `false`
- Updatable during runtime?: ❌

#### `.alphaTest: number`
Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false.
- Default value: `0.001`
- Updatable during runtime?: ✅

#### `.color: Vec3`
Base color.
- Default value: `(1, 1, 1)`
- Updatable during runtime?: ✅

#### `.colorMap: 'sampler0'|RageTexture|false`
Base color texture. An alpha channel may be included. If set to `'sampler0'`, use the actor's default texture.
- Default value: `false`
- Updatable during runtime?: ⚠️

#### `.matcap: RageTexture|false`
The matcap texture.
- Default value: `false`
- Updatable during runtime?: ⚠️

#### `.normalMap: RageTexture|false`
The normal map.
- Default value: `false`
- Updatable during runtime?: ⚠️

#### `.opacity: number`
The base alpha.
- Default value: `1`
- Updatable during runtime?: ✅

#### `.transparent: boolean`
Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded.
- Default value: `false`
- Updatable during runtime?: ❌

#### `.useVertexColors: boolean`
Whether to use the actor's vertex colors to color the material. Among other things, this allows you to color actors individually using `:diffuse()`.
- Default value: `false`
- Updatable during runtime?: ❌

#### `.vertexColorInterpolation: 'linear'|'srgb'`
If using vertex colors, this defines whether to interpolate vertex colors in linear RGB or sRGB space. Linear RGB is more "correct" and can look better in certain cases, while sRGB gives closer results to what you might get using regular NotITG methods like `:diffusetopedge()` and such. Note that the vertex color values themselves are always specified in sRGB space.
- Default value: `'linear'`
- Updatable during runtime?: ❌


## NormalMaterial

A material that visualizes normal vectors as RGB colors.

### Properties

#### `.alphaHash: boolean`
Enable hashed alpha testing. If alpha is lower than a random threshold, the pixel is discarded. This allows for gradations of transparency even while `.transparent` is false, but it looks very noisy.
- Default value: `false`
- Updatable during runtime?: ❌

#### `.alphaMap: 'sampler0'|RageTexture|false`
The alpha channel of this texture is used to modulate the material's alpha. If set to `'sampler0'`, use the actor's default texture.
- Default value: `false`
- Updatable during runtime?: ⚠️

#### `.alphaTest: number`
Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false.
- Default value: `0.001`
- Updatable during runtime?: ✅

#### `.normalMap: RageTexture|false`
The normal map.
- Default value: `false`
- Updatable during runtime?: ⚠️

#### `.opacity: number`
The base alpha.
- Default value: `1`
- Updatable during runtime?: ✅

#### `.transparent: boolean`
Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded.
- Default value: `false`
- Updatable during runtime?: ❌

#### `.useVertexColorAlpha: boolean`
Whether to use the actor's vertex color alpha to modulate the alpha of the material.
- Default value: `false`
- Updatable during runtime?: ❌


## PhongMaterial

A material using the Blinn-Phong shading model.

### Properties

#### `.alphaHash: boolean`
Enable hashed alpha testing. If alpha is lower than a random threshold, the pixel is discarded. This allows for gradations of transparency even while `.transparent` is false, but it looks very noisy.
- Default value: `false`
- Updatable during runtime?: ❌

#### `.alphaTest: number`
Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false.
- Default value: `0.001`
- Updatable during runtime?: ✅

#### `.color: Vec3`
Base color.
- Default value: `(1, 1, 1)`
- Updatable during runtime?: ✅

#### `.colorMap: 'sampler0'|RageTexture|false`
Base color texture. An alpha channel may be included. If set to `'sampler0'`, use the actor's default texture.
- Default value: `false`
- Updatable during runtime?: ⚠️

#### `.emissive: Vec3`
Emissive color.
- Default value: `(0, 0, 0)`
- Updatable during runtime?: ✅

#### `.emissiveMap: RageTexture|false`
Emissive map. Be sure to set `.emissive` to a non-black value to see any effect.
- Default value: `false`
- Updatable during runtime?: ⚠️

#### `.envMap: EnvMap|false`
The environment map.
- Default value: `false`
- Updatable during runtime?: ⚠️

#### `.envMapCombine: 'add'|'mix'|'multiply'`
The math operation used to blend the environment map with the material.
- Default value: `'multiply'`
- Updatable during runtime?: ❌

#### `.envMapRotation: Mat3`
The rotation of the environment map.
- Default value: identity matrix
- Updatable during runtime?: ✅

#### `.envMapStrength: number`
How much the environment map affects the color of the material.
- Default value: `1`
- Updatable during runtime?: ✅

#### `.envMapType: 'reflection'|'refraction'`
Whether to use `.envMap` as a reflection or refraction map.
- Default value: `'reflection'`
- Updatable during runtime?: ❌

#### `.normalMap: RageTexture|false`
The normal map.
- Default value: `false`
- Updatable during runtime?: ⚠️

#### `.opacity: number`
The base alpha.
- Default value: `1`
- Updatable during runtime?: ✅

#### `.refractionRatio: number`
The index of refraction (IOR) of air divided by the IOR of the material. Only has an effect if `.envMapType = 'refraction'`.
- Default value: `0.98`
- Updatable during runtime?: ✅

#### `.shininess: number`
The sharpness of the specular highlight.
- Default value: `32`
- Updatable during runtime?: ✅

#### `.specular: Vec3`
Specular color.
- Default value: `(1, 1, 1)`
- Updatable during runtime?: ✅

#### `.specularMap: RageTexture|false`
Specular map. Affects both the specular color and the environment map.
- Default value: `false`
- Updatable during runtime?: ⚠️

#### `.specularMapColorSpace: 'linear'|'srgb'`
Whether to interpret the specular map data as linear or sRGB. If the specular map is grayscale, this should probably be `'linear'`; if it is colored, this should probably be `'srgb'`.
- Default value: `'linear'`
- Updatable during runtime?: ❌

#### `.transparent: boolean`
Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded.
- Default value: `false`
- Updatable during runtime?: ❌

#### `.useVertexColors: boolean`
Whether to use the actor's vertex colors to color the material. Among other things, this allows you to color actors individually using `:diffuse()`.
- Default value: `false`
- Updatable during runtime?: ❌

#### `.vertexColorInterpolation: 'linear'|'srgb'`
If using vertex colors, this defines whether to interpolate vertex colors in linear RGB or sRGB space. Linear RGB is more "correct" and can look better in certain cases, while sRGB gives closer results to what you might get using regular NotITG methods like `:diffusetopedge()` and such. Note that the vertex color values themselves are always specified in sRGB space.
- Default value: `'linear'`
- Updatable during runtime?: ❌


## UVMaterial

A debug material that visualizes the UV coordinates on an object using red and green values.

### Properties

This material has no additional properties.

## UnlitMaterial

A material that only shows the base color and does not respond to lighting.

### Properties

#### `.alphaHash: boolean`
Enable hashed alpha testing. If alpha is lower than a random threshold, the pixel is discarded. This allows for gradations of transparency even while `.transparent` is false, but it looks very noisy.
- Default value: `false`
- Updatable during runtime?: ❌

#### `.alphaTest: number`
Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false.
- Default value: `0.001`
- Updatable during runtime?: ✅

#### `.color: Vec3`
Base color.
- Default value: `(1, 1, 1)`
- Updatable during runtime?: ✅

#### `.colorMap: 'sampler0'|RageTexture|false`
Base color texture. An alpha channel may be included. If set to `'sampler0'`, use the actor's default texture.
- Default value: `false`
- Updatable during runtime?: ⚠️

#### `.opacity: number`
The base alpha.
- Default value: `1`
- Updatable during runtime?: ✅

#### `.transparent: boolean`
Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded.
- Default value: `false`
- Updatable during runtime?: ❌

#### `.useVertexColors: boolean`
Whether to use the actor's vertex colors to color the material. Among other things, this allows you to color actors individually using `:diffuse()`.
- Default value: `false`
- Updatable during runtime?: ❌

#### `.vertexColorInterpolation: 'linear'|'srgb'`
If using vertex colors, this defines whether to interpolate vertex colors in linear RGB or sRGB space. Linear RGB is more "correct" and can look better in certain cases, while sRGB gives closer results to what you might get using regular NotITG methods like `:diffusetopedge()` and such. Note that the vertex color values themselves are always specified in sRGB space.
- Default value: `'linear'`
- Updatable during runtime?: ❌


