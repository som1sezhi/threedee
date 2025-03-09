# Built-in Materials

Note that all these properties are in addition to the properties provided by the base class.

## DepthMaterial

A material used to visualize the depth of the scene, or to encode depth values
as colors. This material is used internally to draw shadow maps.

### Properties

Name | Type | Updatable during runtime? | Description | Default value
--- | --- | :---: | --- | ---
alphaHash | `boolean` | ❌ | Enable hashed alpha testing. If alpha is lower than a random threshold, the pixel is discarded. This allows for gradations of transparency even while `.transparent` is false, but it looks very noisy. | `false`
alphaMap | `'sampler0'​\|​RageTexture​\|​false` | ⚠️ | The alpha channel of this texture is used to modulate the material's alpha. If set to `'sampler0'`, use the actor's default texture. | `false`
alphaTest | `number` | ✅ | Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false. | `0.001`
opacity | `number` | ✅ | The base alpha. | `1`
packingFormat | `'none'​\|​'rg'​\|​'rgb'` | ❌ | How to pack the depth value into the color channels. `'none'` performs no packing, `'rg'` uses the red and green channels, and `'rgb'` uses the red, green, and blue channels. | `'none'`
transparent | `boolean` | ❌ | Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded. | `false`
useVertexColorAlpha | `boolean` | ❌ | Whether to use the actor's vertex color alpha to modulate the alpha of the material. | `false`

## MatcapMaterial

A material that uses a matcap texture to give an appearance of lighting/shading.

### Properties

Name | Type | Updatable during runtime? | Description | Default value
--- | --- | :---: | --- | ---
alphaHash | `boolean` | ❌ | Enable hashed alpha testing. If alpha is lower than a random threshold, the pixel is discarded. This allows for gradations of transparency even while `.transparent` is false, but it looks very noisy. | `false`
alphaTest | `number` | ✅ | Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false. | `0.001`
color | `Vec3` | ✅ | Base color. | `(1, 1, 1)`
colorMap | `'sampler0'​\|​RageTexture​\|​false` | ⚠️ | Base color texture. An alpha channel may be included. If set to `'sampler0'`, use the actor's default texture. | `false`
matcap | `RageTexture​\|​false` | ⚠️ | The matcap texture. | `false`
normalMap | `RageTexture​\|​false` | ⚠️ | The normal map. | `false`
opacity | `number` | ✅ | The base alpha. | `1`
transparent | `boolean` | ❌ | Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded. | `false`
useVertexColors | `boolean` | ❌ | Whether to use the actor's vertex colors to color the material. Among other things, this allows you to color actors individually using `:diffuse()`. | `false`
vertexColorInterpolation | `'linear'​\|​'srgb'` | ❌ | If using vertex colors, this defines whether to interpolate vertex colors in linear RGB or sRGB space. Linear RGB is more "correct" and can look better in certain cases, while sRGB gives closer results to what you might get using regular NotITG methods like `:diffusetopedge()` and such. Note that the vertex color values themselves are always specified in sRGB space. | `'linear'`

## NormalMaterial

A material that visualizes normal vectors as RGB colors.

### Properties

Name | Type | Updatable during runtime? | Description | Default value
--- | --- | :---: | --- | ---
alphaHash | `boolean` | ❌ | Enable hashed alpha testing. If alpha is lower than a random threshold, the pixel is discarded. This allows for gradations of transparency even while `.transparent` is false, but it looks very noisy. | `false`
alphaMap | `'sampler0'​\|​RageTexture​\|​false` | ⚠️ | The alpha channel of this texture is used to modulate the material's alpha. If set to `'sampler0'`, use the actor's default texture. | `false`
alphaTest | `number` | ✅ | Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false. | `0.001`
normalMap | `RageTexture​\|​false` | ⚠️ | The normal map. | `false`
opacity | `number` | ✅ | The base alpha. | `1`
transparent | `boolean` | ❌ | Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded. | `false`
useVertexColorAlpha | `boolean` | ❌ | Whether to use the actor's vertex color alpha to modulate the alpha of the material. | `false`

## PhongMaterial

A material using the Blinn-Phong shading model.

### Properties

Name | Type | Updatable during runtime? | Description | Default value
--- | --- | :---: | --- | ---
alphaHash | `boolean` | ❌ | Enable hashed alpha testing. If alpha is lower than a random threshold, the pixel is discarded. This allows for gradations of transparency even while `.transparent` is false, but it looks very noisy. | `false`
alphaTest | `number` | ✅ | Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false. | `0.001`
color | `Vec3` | ✅ | Base color. | `(1, 1, 1)`
colorMap | `'sampler0'​\|​RageTexture​\|​false` | ⚠️ | Base color texture. An alpha channel may be included. If set to `'sampler0'`, use the actor's default texture. | `false`
emissive | `Vec3` | ✅ | Emissive color. | `(0, 0, 0)`
emissiveMap | `RageTexture​\|​false` | ⚠️ | Emissive map. Be sure to set `.emissive` to a non-black value to see any effect. | `false`
envMap | `EnvMap​\|​false` | ⚠️ | The environment map. | `false`
envMapCombine | `'add'​\|​'mix'​\|​'multiply'` | ❌ | The math operation used to blend the environment map with the material. | `'multiply'`
envMapRotation | `Mat3` | ✅ | The rotation of the environment map. | identity matrix
envMapStrength | `number` | ✅ | How much the environment map affects the color of the material. | `1`
envMapType | `'reflection'​\|​'refraction'` | ❌ | Whether to use `.envMap` as a reflection or refraction map. | `'reflection'`
normalMap | `RageTexture​\|​false` | ⚠️ | The normal map. | `false`
opacity | `number` | ✅ | The base alpha. | `1`
refractionRatio | `number` | ✅ | The index of refraction (IOR) of air divided by the IOR of the material. Only has an effect if `.envMapType = 'refraction'`. | `0.98`
shininess | `number` | ✅ | The sharpness of the specular highlight. | `32`
specular | `Vec3` | ✅ | Specular color. | `(1, 1, 1)`
specularMap | `RageTexture​\|​false` | ⚠️ | Specular map. Affects both the specular color and the environment map. | `false`
specularMapColorSpace | `'linear'​\|​'srgb'` | ❌ | Whether to interpret the specular map data as linear or sRGB. If the specular map is grayscale, this should probably be `'linear'`; if it is colored, this should probably be `'srgb'`. | `'linear'`
transparent | `boolean` | ❌ | Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded. | `false`
useVertexColors | `boolean` | ❌ | Whether to use the actor's vertex colors to color the material. Among other things, this allows you to color actors individually using `:diffuse()`. | `false`
vertexColorInterpolation | `'linear'​\|​'srgb'` | ❌ | If using vertex colors, this defines whether to interpolate vertex colors in linear RGB or sRGB space. Linear RGB is more "correct" and can look better in certain cases, while sRGB gives closer results to what you might get using regular NotITG methods like `:diffusetopedge()` and such. Note that the vertex color values themselves are always specified in sRGB space. | `'linear'`

## UVMaterial

A debug material that visualizes the UV coordinates on an object using red and green values.

This material has no additional properties.

## UnlitMaterial

A material that only shows the base color and does not respond to lighting.

### Properties

Name | Type | Updatable during runtime? | Description | Default value
--- | --- | :---: | --- | ---
alphaHash | `boolean` | ❌ | Enable hashed alpha testing. If alpha is lower than a random threshold, the pixel is discarded. This allows for gradations of transparency even while `.transparent` is false, but it looks very noisy. | `false`
alphaTest | `number` | ✅ | Pixels with alpha lower than this value will be discarded. This works even if `.transparent` is false. | `0.001`
color | `Vec3` | ✅ | Base color. | `(1, 1, 1)`
colorMap | `'sampler0'​\|​RageTexture​\|​false` | ⚠️ | Base color texture. An alpha channel may be included. If set to `'sampler0'`, use the actor's default texture. | `false`
opacity | `number` | ✅ | The base alpha. | `1`
transparent | `boolean` | ❌ | Whether the material is transparent, or is able to be transparent via a texture. If false, all pixels will either be fully opaque or discarded. | `false`
useVertexColors | `boolean` | ❌ | Whether to use the actor's vertex colors to color the material. Among other things, this allows you to color actors individually using `:diffuse()`. | `false`
vertexColorInterpolation | `'linear'​\|​'srgb'` | ❌ | If using vertex colors, this defines whether to interpolate vertex colors in linear RGB or sRGB space. Linear RGB is more "correct" and can look better in certain cases, while sRGB gives closer results to what you might get using regular NotITG methods like `:diffusetopedge()` and such. Note that the vertex color values themselves are always specified in sRGB space. | `'linear'`

