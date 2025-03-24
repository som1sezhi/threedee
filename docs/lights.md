# Lights

There are a few varieties of lights you can add to your scene.

## `Light`

Base class for all lights.

### Properties

#### `Light.color: Vec3`
Light color.
- Default value: `(1, 1, 1)` (white)
- Updatable during runtime: ✅

#### `Light.intensity: number`
Light intensity (essentially a multiplier for the color).
- Default value: `1`
- Updatable during runtime: ✅

#### `Light.position: Vec3`
The position of this object.
- Default value: `(0, 0, 0)`
- Updatable during runtime: ✅

#### `Light.rotation: Quat`
The rotation of this object.
- Default value: identity quaternion (no rotation)
- Updatable during runtime: ✅

#### `Light.viewMatrix: Mat4`
The object's view matrix. Automatically updated whenever `position` or `rotation` is updated via `:update()` or `:lookAt()`.
- This property should be treated as **read-only**.

### Methods

#### `Light:lookAt(eyePos: Vec3, targetPos: Vec3, up?: Vec3)`
Positions `self` at `eyePos`, then rotates it to look at `targetPos`, with its viewpoint oriented with its up vector pointed in the direction hinted by `up`. If `up` is not given, a default of `(0, -1, 0)` (the world up-direction) will be used.

#### `Light:update(props: table)`
Updates the properties of `self` according to `props`.

## `AmbientLight: Light`

An ambient light, lighting up all surfaces with a uniform
color/intensity. Position and rotation is essentially ignored.

### Properties

See [`Light`](#properties) for more properties.

This class has no properties of its own.

### Methods

See [`Light`](#methods) for more methods.

#### `AmbientLight:new(color: Vec3, intensity: number): AmbientLight`
Creates a new AmbientLight.

## `PointLight: Light`

Emits light from a single point in all directions.

### Properties

See [`Light`](#properties) for more properties.

#### `PointLight.castShadows: boolean`
Whether this light casts shadows.
- Default value: `false`
- Updatable during runtime: ❌

#### `PointLight.linearAttenuation: number`
Linear attenuation factor. This value should probably be kept quite small. As you go further from the light, the light dims by a factor of `1 / (1 + linearAttenuation * distance + quadraticAttenuation * distance^2)`.
- Default value: `0`
- Updatable during runtime: ✅

#### `PointLight.quadraticAttenuation: number`
Quadratic attenuation factor. This value should porbably be kept quite small. As you go further from the light, the light dims by a factor of `1 / (1 + linearAttenuation * distance + quadraticAttenuation * distance^2)`.
- Default value: `0.000002`
- Updatable during runtime: ✅

#### `PointLight.shadow: StandardPerspectiveShadow`
The light's shadow.
- Default value: a StandardShadow using a PerspectiveCamera with `.fov = math.rad(90)`, `.nearDist = 100`, and `.farDist = 3000`.
- Updatable during runtime: ❌ (but you may call `:update()` on the object itself)

### Methods

See [`Light`](#methods) for more methods.

#### `PointLight:new(color: Vec3, intensity: number, position: Vec3): PointLight`
Creates a new PointLight.

## `DirLight: Light`

Emits light in a single direction. This models a light source that is
infinitely far away, with light rays going in parallel.

Note that `.position` still matters for this light; if shadows are
enabled, the light's shadow map will be taken from the POV of that
position.

### Properties

See [`Light`](#properties) for more properties.

#### `DirLight.castShadows: boolean`
Whether this light casts shadows.
- Default value: `false`
- Updatable during runtime: ❌

#### `DirLight.shadow: StandardOrthographicShadow`
The light's shadow.
- Default value: a StandardShadow using an OrthographicCamera with `.nearDist = 100` and `.farDist = 3000`.
- Updatable during runtime: ❌ (but you may call `:update()` on the object itself)

### Methods

See [`Light`](#methods) for more methods.

#### `DirLight:new(color: Vec3, intensity: number): DirLight`
Creates a new DirLight.

## `SpotLight: Light`

A spotlight, emitting light in a cone pointed in a particular direction.

### Properties

See [`Light`](#properties) for more properties.

#### `SpotLight.angle: number`
The angular radius of the spotlight, which should be a number in the interval [0, pi/2). Note that updating this property via `:update()` will also update the `.fov` property of this light's shadow camera.
- Default value: `math.rad(45)`
- Updatable during runtime: ✅

#### `SpotLight.castShadows: boolean`
Whether this light casts shadows.
- Default value: `false`
- Updatable during runtime: ❌

#### `SpotLight.colorMap: RageTexture|false`
If present, this texture is used to modulate the color of the light. This can be used to implement light cookie effects. RGB textures are allowed to be used. Note that the shadow camera's matrices are used to calculate the UV coordinates for this texture, so be aware of this when fiddling with the shadow camera's properties.
- Default value: `false`
- Updatable during runtime: ⚠️

#### `SpotLight.linearAttenuation: number`
Linear attenuation factor. This value should probably be kept quite small. As you go further from the light, the light dims by a factor of `1 / (1 + linearAttenuation * distance + quadraticAttenuation * distance^2)`.
- Default value: `0`
- Updatable during runtime: ✅

#### `SpotLight.penumbra: number`
A number in [0, 1] representing the proportion of the spotlight radius used to transition between total darkness and full brightness. Lower values give a sharper edge; higher values give a softer edge.
- Default value: `0`
- Updatable during runtime: ✅

#### `SpotLight.quadraticAttenuation: number`
Quadratic attenuation factor. This value should probably be kept quite small. As you go further from the light, the light dims by a factor of `1 / (1 + linearAttenuation * distance + quadraticAttenuation * distance^2)`.
- Default value: `0.000002`
- Updatable during runtime: ✅

#### `SpotLight.shadow: StandardPerspectiveShadow`
The light's shadow.
- Default value: a StandardShadow using a PerspectiveCamera with `.fov = light.angle * 2`, `aspectRatio = 1`, `nearDist = 100`, and `farDist = 3000`.
- Updatable during runtime: ❌ (but you may call `:update()` on the object itself)

### Methods

See [`Light`](#methods) for more methods.

#### `SpotLight:new(color?: Vec3, intensity?: number, position?: Vec3, rotation?: Quat, angle?: number, penumbra?: number): SpotLight`
Creates a new SpotLight.

