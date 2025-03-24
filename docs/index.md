# threedee docs

## A note about properties that are "updatable during runtime"

Note: these docs denote many properties/attributes of many classes as "updatable during runtime". Here, "runtime" basically means "during modfile gameplay", i.e. code that runs inside a definemod, node, func, perframe, func_ease, drawfunction, etc. "Updatable during runtime" means that you can modify the value of this property during runtime, and threedee will handle this update correctly. Almost always, this modification should be done via the object's `:update()` method, in order to let threedee know about the update and handle it properly. For example:

```lua
-- all :update() functions take in a table containing
-- the updates that should be applied:
myMaterial:update{
    color = td.color(1, 0, 0),
    shininess = 50
}
```

> The exception to this are SceneActors, whose updatable properties can just be updated via a simple assignment, e.g.:
> ```lua
> -- SceneActors don't have :update() methods,
> -- just do this instead
> myModel.castShadows = true
> ```

Note that *all* documented properties (aside the ones denoted as read-only by these docs) can be assigned values and modified *before* runtime. Specifically, you are allowed to set/change their values *before* calling `Scene:finalize()`. Updating their values after scene finalization but before runtime (i.e. before mods.lua has finished executing in its entirety) is not supported. You can set/change these properties via simple assignment, or by passing in their values via the class's `:new()` constructor (if supported).

The following emojis are used in these docs to denote a property's ability to be updated during runtime:

- ✅: This property is allowed to be updated during runtime.
- ⚠️: This property may only be updated during runtime to a value with the *same type/characteristics* as the previously set value. For example:
    - For a property with type `'sampler0'|RageTexture|false`:
        - If it was set to a `RageTexture` before runtime, its value can only be changed to another `RageTexture`.
        - If it was set to `'sampler0'` or `false` before runtime, it *should not* be updated to any other value at runtime.
    - A property set to an `EnvMap` may only be changed to another `EnvMap` with the *same properties* as the previous value (mapping, color format, etc.), besides the texture itself.
- ❌: This property should not be modified at runtime. You must set this property's value *before* runtime, either via an assignment statement or by passing it in via the `:new()` constructor, where supported.
    - Remember that if the value of this property is an object that itself has an `:update()` method, you are allowed to call this method during runtime to update properties of this object.

## API reference

- [Scene](scene.md)
- [Cameras](cameras.md)
    - [Camera (base class)](cameras.md#camera)
    - [PerspectiveCamera](cameras.md#perspectivecamera-camera)
    - [OrthographicCamera](cameras.md#orthographiccamera-camera)
- [SceneActors](sceneactors.md)
    - [SceneActor (base class)](sceneactors.md#sceneactor)
    - [ActorWithMaterial](sceneactors.md#actorwithmaterial-sceneactor)
    - [MeshActor](sceneactors.md#meshactor-actorwithmaterial)
    - [NoteFieldProxy](sceneactors.md#notefieldproxy-actorwithmaterial)
    - [SceneActorFrame](sceneactors.md#sceneactorframe-sceneactor)
- Materials:
    - [Material (base class)](material.md)
    - [Built-in Material types](materials.md)
        - [DepthMaterial](materials.md#depthmaterial)
        - [MatcapMaterial](materials.md#matcapmaterial)
        - [NormalMaterial](materials.md#normalmaterial)
        - [PhongMaterial](materials.md#phongmaterial)
        - [UVMaterial](materials.md#uvmaterial)
        - [UnlitMaterial](materials.md#unlitmaterial)
- [Lights](lights.md)
    - [Light (base class)](lights.md#light)
    - [AmbientLight](lights.md#ambientlight-light)
    - [PointLight](lights.md#pointlight-light)
    - [DirLight](lights.md#dirlight-light)
    - [SpotLight](lights.md#spotlight-light)
- [Shadows](shadows.md)
    - [StandardShadow](shadows.md#standardshadow)
    - [StandardPerspectiveShadow](shadows.md#standardperspectiveshadow-standardshadow)
    - [StandardOrthographicShadow](shadows.md#standardorthographicshadow-standardshadow)
- [Math utilities](math.md)
    - [Vec3](math.md#vec3)
    - [Vec4](math.md#vec4)
    - [Mat3](math.md#mat3)
    - [Mat4](math.md#mat4)
    - [Quat](math.md#quat)
    - [Euler](math.md#euler)
- [Color utilities](color.md)
- [EnvMap](envmap.md)
