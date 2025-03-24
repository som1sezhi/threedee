# Shadows

Some light types support casting shadows. To do this, the following must be set:

- On the scene, the `.doShadows` property must be set to `true`.
- On the light, the `.castShadows` property must be set to `true`.
- One or more SceneActors must have their `.castShadows` and/or `.receiveShadows` properties set to `true`.

The light's `.shadow` property holds an object representing the light's shadow, whose API is detailed below.

## `StandardShadow`

A regular shadow map implementation, using a single camera and an RGB-packed depth format.

### Properties

#### `StandardShadow.bias: number`
A bias value to add to a pixel's depth value before testing it against the shadow map. Small negative values can help in mitigating the appearance of strip-like "shadow acne" artifacts, at the cost of causing shadows to appear slightly detached from their casters.
- Default value: `-0.003`
- Updatable during runtime: ✅

#### `StandardShadow.camera: Camera`
The camera used to draw the shadow map.
- Default value: a PerspectiveCamera with all the values set to default.
- Updatable during runtime: ❌ (but you may call `:update()` on the object itself)

#### `StandardShadow.shadowMapAft: ActorFrameTexture?`
The AFT holding the shadow map texture. This starts off as `nil`, with an AFT being assigned to this property only during scene finalization, and only if the shadow is active.
- This property should be treated as **read-only**.

### Methods

#### `StandardShadow:new(props: StandardShadow.P): StandardShadow`
Creates a new StandardShadow. props is a table that contains one or more properties that will be passed into the new StandardShadow; missing properties will be initialized with their defaults.

You likely don't actually need to call this yourself, as lights that support shadows already come with their own instances of StandardShadow, whose properties can be modified for your use.

#### `StandardShadow:drawShadowMap(scene: Scene)`
Called internally to draw the shadow map and save it to self.shadowMapAft.

#### `StandardShadow:update(props: table)`
Updates the properties of `self` according to `props`.

## `StandardPerspectiveShadow: StandardShadow`

A StandardShadow with the camera type limited to PerspectiveCamera. Appropriate for PointLights and SpotLights.

### Properties

See [`StandardShadow`](#properties) for more properties.

This class has no properties of its own.

### Methods

See [`StandardShadow`](#methods) for more methods.

This class has no methods of its own.

## `StandardOrthographicShadow: StandardShadow`

A StandardShadow with the camera type limited to OrthographicCamera. Appropriate for DirLights.

### Properties

See [`StandardShadow`](#properties) for more properties.

This class has no properties of its own.

### Methods

See [`StandardShadow`](#methods) for more methods.

This class has no methods of its own.

