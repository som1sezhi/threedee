# SceneActors

In order to add an actor to your scene, you must first wrap it in a SceneActor object. This allows threedee to keep track of some extra information associated with the actor, e.g. its material.

The SceneActor object will forward all actor method calls to the actor itself, meaning you can call actor methods on a SceneActor as if it was the original actor:

```lua
-- assume myActor is a global variable containing an actor
myActor = td.MeshActor:new(myActor, myMaterial)
-- now myActor is a SceneActor (specifically a MeshActor), but
-- you can still call actor methods on it
myActor:xyz(0, 100, 0)
myActor:rotationx(0, 0, 0)
```

However, you should refrain from calling these actor methods, as they probably won't work:

- `Actor:cullmode()` (see `MeshActor.cullMode` for an alternative)

## A note about emojis

Since SceneActors don't have an `:update()` method, these emojis have a slightly different meaning here than in other pages of these docs:
- ✅: This property is allowed to be modified after scene finalization/during "runtime", via simple assignment (e.g. `mySceneActor.cullMode = 'none'`).
- ❌: This property should not be modified at runtime. You can set it anytime *before* scene finalization by simple assignment.


## `SceneActor`

Base class for actors that can be added to a scene using `Scene:add()`.

You shouldn't instantiate this base class directly; instead use one of its subclasses.

### Properties

#### `SceneActor.actor: Actor`
The wrapped actor.
- This property should be treated as **read-only**.

### Methods

#### `SceneActor:scale(scale: number): SceneActor`
A convenience method for uniformly scaling the actor. Equivalent to `Actor:zoom(scale):zoomz(scale)`. Returns `self`.

#### `SceneActor:zoomxyz(scaleX: number, scaleY: number, scaleZ: number): SceneActor`
A convenience method for calling `:zoomx()`, `:zoomy()`, and `:zoomz()` at the same time. Returns `self`.



## `ActorWithMaterial: SceneActor`

Base class for actors that can be associated with a material.

### Properties
See [`SceneActor`](#sceneactor) for more properties.

#### `ActorWithMaterial.material: Material`
The associated material.
- Updatable during runtime: ❌

#### `ActorWithMaterial.castShadows: boolean`
Whether this actor casts shadows.
- Updatable during runtime: ✅

#### `ActorWithMaterial.receiveShadows: boolean`
Whether this actor can receive shadows.
- Updatable during runtime: ✅



## `MeshActor: ActorWithMaterial`

A Sprite, Model, or Polygon associated with a material. Accessible from `td` as `td.MeshActor`.

### Properties
See [`ActorWithMaterial`](#actorwithmaterial-sceneactor) for more properties.

#### `MeshActor.cullMode: 'none'|'front'|'back'`
What cull mode to use when drawing the actor.
- Default value: `'back'`
- Updatable during runtime: ✅

#### `MeshActor.shadowCullMode: 'none'|'front'|'back'`
What cull mode to use when drawing the actor to a shadow map.
- Default value: `'none'`
- Updatable during runtime: ✅

### Methods
See [`SceneActor`](#sceneactor) for more methods.

#### `MeshActor:new(actor: Model|Polygon|Sprite, material: Material): MeshActor`
Creates and returns a new MeshActor, wrapping `actor` and associating it with `material`.



## `NoteFieldProxy: ActorWithMaterial`

A notefield proxy associated with a material. Accessible from `td` as `td.NoteFieldProxy`.

> **Note:** If you use this, you probably want to set the `zbuffer`, `ztest`, and `receptorzbuffer` mods to 100 for the player being proxied in order for the 3D layering stuff to work out mostly-correctly.

> **Note:** There may be some parts of the notefield's noteflash effect which cannot have shaders applied at all, even with `.useShaderFuck` set to true. (I believe this to be caused by the game using OpenGL's fixed-function pipeline to render these parts.) This problem can manifest as out-of-place noteflashes appearing on top of the screen. The most flexible workaround is probably to just avoid positioning the notefield's receptors at world-space coordinates with both positive X and positive Y values, as that way these noteflashes will be positioned off-screen.

### Properties
See [`ActorWithMaterial`](#actorwithmaterial-sceneactor) for more properties.

#### `NoteFieldProxy.player: Player`
The player whose notefield this actor is proxying.
- This property should be treated as **read-only**.

#### `NoteFieldProxy.useShaderFuck: boolean`
Whether to use `DISPLAY:ShaderFuck()` to apply the material when drawing this actor. Doing this allows the material to be applied to parts of the notefield that otherwise cannot have the material applied (e.g. noteflashes), but removes the ability for different parts of the notefield (arrows, holds, etc.) to have different materials applied.
- Default value: `true`
- Updatable during runtime: ✅

#### `NoteFieldProxy.arrowMaterial: Material?`
If set, and if `self.useShaderFuck` is false, this material will be used to draw the arrows instead of `self.material`.
- Default value: `nil`
- Updatable during runtime: ❌

#### `NoteFieldProxy.holdMaterial: Material?`
If set, and if `self.useShaderFuck` is false, this material will be used to draw the holds instead of `self.material`.
- Default value: `nil`
- Updatable during runtime: ❌

#### `NoteFieldProxy.receptorMaterial: Material?`
If set, and if `self.useShaderFuck` is false, this material will be used to draw the receptors instead of `self.material`.
- Default value: `nil`
- Updatable during runtime: ❌

#### `NoteFieldProxy.arrowPathMaterial: Material?`
If set, and if `self.useShaderFuck` is false, this material will be used to draw the arrowpath instead of `self.material`.
- Default value: `nil`
- Updatable during runtime: ❌

### Methods
See [`SceneActor`](#sceneactor) for more methods.

#### `NoteFieldProxy:new(actor: ActorProxy, material: Material, player: Player): NoteFieldProxy`
Creates a new wrapped notefield proxy, and sets the proxy target to the given player's notefield.



## `SceneActorFrame: SceneActor`

A SceneActor that wraps an ActorFrame. Accessible from `td` as `td.SceneActorFrame`.

Example:
```lua
-- assume aframe is an ActorFrame with child1 and child2 as children
child1 = td.MeshActor:new(child1, mat)
child2 = td.MeshActor:new(child2, mat)
aframe = td.SceneActorFrame:new(aframe)
aframe:add({ child1, child2 })
-- only add the SceneActorFrame to the scene, not its individual children
scene:add(aframe)
```

SceneActorFrame works by setting a drawfunction on the ActorFrame to manually call the `:Draw()` methods of the wrapped SceneActor children. If you want, you can set your own drawfunction after creating the SceneActorFrame, as long as you add all the children to be drawn to the SceneActorFrame using `SceneActorFrame:add()` and you call the `:Draw()` methods on the wrapped SceneActors instead of the original bare Actors.

### Properties
See [`SceneActor`](#sceneactor) for more properties.

#### `SceneActorFrame.children: SceneActor[]`
The SceneActorFrame's children.
- This property should be treated as **read-only**.

### Methods
See [`SceneActor`](#sceneactor) for more methods.

#### `SceneActorFrame:new(aframe: ActorFrame): SceneActorFrame`
Creates a new wrapped ActorFrame. Also sets a simple drawfunction on `aframe` that just draws all its children.

#### `SceneActorFrame:add(sceneActor: SceneActor|SceneActor[])`
Add a child or children to this SceneActorFrame. The children should all be SceneActors that wrap an actual direct child of the underlying ActorFrame.