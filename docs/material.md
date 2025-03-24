# Material (base class)

## `Material`

Base class for all materials.

### Properties

#### `Material.fragSource: string?`
Fragment shader source code. Material subclasses will override this with their own source code. If `.vertSource` and `.fragSource` are not both present by compile time, threedee will not compile a new shader, but will instead retain the shader program pre-existing inside `self.shader`.
- Default value: `nil`
- Updatable during runtime: ❌

#### `Material.shader: RageShaderProgram`
The material's shader program. If not supplied via `Material:new()`, a shader program will be automatically supplied from one of the actors in the `_td_materialActors` ActorFrame in threedee.xml.
- Updatable during runtime: ❌

#### `Material.vertSource: string?`
Vertex shader source code. Material subclasses will override this with their own source code. If `.vertSource` and `.fragSource` are not both present by compile time, threedee will not compile a new shader, but will instead retain the shader program pre-existing inside `self.shader`.
- Default value: `nil`
- Updatable during runtime: ❌

### Methods

#### `Material:new(initProps?: <M:Material>): <M:Material>`
Creates a new material. If present, `initProps` should be a table containing
one or more material properties that will be passed into the new material.

#### `Material:addMixin(mixin: MaterialMixin)`
Add a new mixin to this material after creation.

#### `Material:compile(scene: Scene)`
Compiles the shader, setting the #defines according to the
material and scene properties.
Does not set any uniforms yet.
This method is called by `Scene:finalize()`.

#### `Material:onBeforeDraw(act: ActorWithMaterial)`
Called before drawing an actor with this material.

#### `Material:onBeforeFirstDraw(scene: Scene)`
Called just before drawing the scene for the first time.
This function ensures that all the shader uniforms are initialized before drawing.

#### `Material:onFrameStart(scene: Scene)`
Called at the beginning of each frame.

#### `Material:setDefines(scene: Scene)`
Sets all the shader #defines according to the material and scene properties.
This is called by `Material:compile()`.

#### `Material:update(props: table)`
Updates the properties of `self` according to `props`.

