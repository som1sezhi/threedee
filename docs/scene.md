# Scene

The Scene class is in charge of doing the actual drawing of the 3D scene. Currently, threedee does not officially support more than one Scene per modfile.

## `Scene`

### Properties

#### `Scene.actors: SceneActor[]`
The scene's actors.
- This property should be treated as **read-only**.

#### `Scene.aframe: ActorFrame`
The scene ActorFrame.
- This property should be treated as **read-only**.

#### `Scene.background: EnvMap|RageTexture|Vec3`
The scene background. If set to a Vec3 (i.e. a color), a solid-color background will be drawn. If set to a RageTexture, a static full-screen image will be drawn. If set to an EnvMap, a 3D environment map will be drawn.
- Default value: `(0, 0, 0)` (black)
- Updatable during runtime: ⚠️

#### `Scene.backgroundIntensity: number`
The background brightness.
- Default value: `1`
- Updatable during runtime: ✅

#### `Scene.backgroundRotation: Mat3`
The environment map rotation, if using an environment map for the background.
- Default value: identity matrix
- Updatable during runtime: ✅

#### `Scene.camera: Camera`
The camera used to draw the scene.
- Updatable during runtime: ❌ (but you may call `:update()` on the object itself)

#### `Scene.doShadows: boolean`
Global toggle for shadows.
- Default value: `true`
- Updatable during runtime: ✅

#### `Scene.drawBackgroundFirst: boolean`
If true, draw the background first, before any of the scene's actors; if false, draw the background last. Setting this to false is slightly more performant (no time wasted drawing parts of the background that would be covered up), but may lead to z-buffer issues with notefield receptors if the receptors are positioned directly on top of the background.
- Default value: `true`
- Updatable during runtime: ✅

#### `Scene.materials: Material[]`
The scene's materials.
- This property should be treated as **read-only**.

#### `Scene.shadowMapFilter: 'none'|'pcf_bilinear'|'pcf_simple'`
The kind of filtering applied to the shadow map when using shadows. In order of increasing visual quality (and cost): `'none'` does no filtering and can result in jagged-looking shadows; `'pcf_simple'` does percentage-closer filtering (PCF) with a 3x3 neighborhood of texels; and `'pcf_bilinear'` does PCF with a 3x3 grid of bilinear samples using data from a 4x4 neighborhood of texels.
- Default value: `'pcf_simple'`
- Updatable during runtime: ❌

### Methods

#### `Scene:new(aframe: ActorFrame, camera: Camera): Scene`
Creates a new scene with the given ActorFrame and Camera.

#### `Scene:add(sceneActor: SceneActor)`
Adds a new actor to the scene. The SceneActor should wrap a direct
child of `self.aframe`.

#### `Scene:addLight(light: Light)`
Adds a light to the scene.

#### `Scene:draw()`
This is the method called internally by the scene ActorFrame's
drawfunction to draw the scene.

#### `Scene:drawActors()`
Calls all the scene actors' `:Draw()` methods once.
You can override this method to set your own scene "drawfunction", similar
to what you might usually use NotITG drawfunctions for (e.g. to draw
the same actor multiple times per frame). Make sure to call the `:Draw()`
methods on the SceneActors instead of the bare, unwrapped actors.

#### `Scene:finalize()`
Finalizes the scene. This compiles all the materials' shaders and
does some other other bookkeeping work. After calling this, many
properties of the Scene/SceneActors/lights/materials/etc. are effectively
"frozen" and should not be changed. For example, you may not add
any more actors or lights to the scene after calling this.

#### `Scene:update(props: table)`
Updates the properties of `self` according to `props`.

