# EnvMap

An `EnvMap` is just a `RageTexture` associated with some additional information that allows it to be interpreted as an environment map.

#### `td.envMap(args: EnvMapArgs): EnvMap`

You can use the `td.envMap()` function to help you create EnvMap objects easier. `args` should be a table containing one or more properties that will be passed into the new EnvMap object. The only required property is `.texture`; other properties will be set to their default values if excluded.

### `EnvMap` properties

Note that all of these properties should be considered read-only after creation.

#### `EnvMap.colorFormat: 'rgb'`

How each pixel's color is represented in the texture. Currently only one format is supported, the standard `'rgb'`.
- Default value: `'rgb'`

#### `EnvMap.isEnvMap: true`

A flag used internally to indicate that this object is an EnvMap.

#### `EnvMap.mapping: 'sphere'|'equirect'`

How the environment is mapped onto the texture (sphere map or equirectangular map).

- Note that a sphere map is not recommended for general-purpose environment mapping due to severe artifacts on the back side of the mapped sphere.
- A texture with a 2:1 aspect ratio is recommended for equirectangular mapping.
- Default value: `'equirect'`

#### `EnvMap.texture: RageTexture`

The texture of the environment map. This texture should have dimensions that are powers of 2 in order to work correctly.
