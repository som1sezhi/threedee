# Cameras

There are two types of cameras available in threedee: PerspectiveCamera and OrthographicCamera.

## `Camera`

Base class for all cameras.

### Properties

#### `Camera.farDist: number`
Distance to the far plane. Geometry farther than this will be clipped.
- Default value: `2000`
- Updatable during runtime: ✅

#### `Camera.nearDist: number`
Distance to the near plane. Geometry closer than this will be clipped.
- Default value: `1`
- Updatable during runtime: ✅

#### `Camera.position: Vec3`
The position of this object.
- Default value: `(0, 0, 0)`
- Updatable during runtime: ✅

#### `Camera.projMatrix: Mat4`
The camera's projection matrix. Automatically updated whenever a camera property that would affect it is updated via `:update()`.
- This property should be treated as **read-only**.

#### `Camera.rotation: Quat`
The rotation of this object.
- Default value: identity quaternion (no rotation)
- Updatable during runtime: ✅

#### `Camera.viewMatrix: Mat4`
The object's view matrix. Automatically updated whenever `position` or `rotation` is updated via `:update()` or `:lookAt()`.
- This property should be treated as **read-only**.

### Methods

#### `Camera:lookAt(eyePos: Vec3, targetPos: Vec3, up?: Vec3)`
Positions `self` at `eyePos`, then rotates it to look at `targetPos`, with its viewpoint oriented with its up vector pointed in the direction hinted by `up`. If `up` is not given, a default of `(0, -1, 0)` (the world up-direction) will be used.

#### `Camera:update(props: table)`
Updates the properties of `self` according to `props`.

## `PerspectiveCamera: Camera`

A camera utilizing perspective projection.

### Properties

See [`Camera`](#properties) for more properties.

#### `PerspectiveCamera.aspectRatio: number`
The aspect ratio of the camera frustum.
- Default value: `SCREEN_WIDTH / SCREEN_HEIGHT`
- Updatable during runtime: ✅

#### `PerspectiveCamera.fov: number`
The vertical FOV, in radians.
- Default value: `math.rad(45)` (45 degrees)
- Updatable during runtime: ✅

### Methods

See [`Camera`](#methods) for more methods.

#### `PerspectiveCamera:new(attrs: PerspectiveCamera.P): PerspectiveCamera`
Creates a new camera. `attrs` is a table that contains
one or more camera properties that will be passed into the
new camera; missing properties will be initialized with their
defaults.

## `OrthographicCamera: Camera`

A camera utilizing orthographic projection.

### Properties

See [`Camera`](#properties) for more properties.

#### `OrthographicCamera.bottom: number`
Bottom plane y-coordinate.
- Default value: `SCREEN_HEIGHT / 2`
- Updatable during runtime: ✅

#### `OrthographicCamera.left: number`
Left plane x-coordinate.
- Default value: `-SCREEN_WIDTH / 2`
- Updatable during runtime: ✅

#### `OrthographicCamera.right: number`
Right plane x-coordinate.
- Default value: `SCREEN_WIDTH / 2`
- Updatable during runtime: ✅

#### `OrthographicCamera.top: number`
Top plane y-coordinate.
- Default value: `-SCREEN_HEIGHT / 2`
- Updatable during runtime: ✅

### Methods

See [`Camera`](#methods) for more methods.

#### `OrthographicCamera:new(attrs: OrthographicCamera.P): OrthographicCamera`
Creates a new camera. `attrs` is a table that contains
one or more camera properties that will be passed into the
new camera; missing properties will be initialized with their
defaults.

