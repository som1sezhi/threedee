---@diagnostic disable: lowercase-global
if not P1 or not P2 then
	backToSongWheel('Two Player Mode Required')
	return
end

for pn = 1, 2 do
	P[pn]:hidden(1)
end

-- your code goes here here:

local td = require 'threedee'

-- create a camera and scene -----------------------------------

local camera = td.PerspectiveCamera:new{
    fov = math.rad(60) -- vertical FOV of 60 degrees
}
-- place the camera at (900, -150, 0) and rotate it to look at (0, 0, 0)
camera:lookAt(td.Vec3:new(900, -150, 0), td.Vec3:new(0, 0, 0))

-- create the scene
-- this requires the scene ActorFrame, as well as a camera to
-- view the scene with
local scene = td.Scene:new(world, camera)
-- set the scene background to dark blue
scene.background = td.color(0, 0, 0.2)

-- create some materials ---------------------------------------

local redMaterial = td.PhongMaterial:new{
	color = td.color(1, 0, 0)
}

local texturedMaterial = td.PhongMaterial:new{
	-- you can pass in a RageTexture to use that as the material's texture,
	-- or 'sampler0' to use the actor's default texture
	colorMap = 'sampler0',
    -- allow the material to contain transparent parts
	transparent = true
}

-- assign materials to actors ----------------------------------

-- use MeshActor to assign materials to Sprites, Models, or Polygons.
-- this returns a MeshActor object, which is basically just a wrapper around
-- the original actor.
-- in fact, we can just assign it back into the actor variable
cube = td.MeshActor:new(cube, redMaterial)
-- we can still call the usual actor methods
cube:xyz(-250, 0, 0)
cube:rotationxyz2(30, 20, 30)
cube:scale(1.5) -- new convenience method provided by MeshActor
-- add the actor to the scene
scene:add(cube)

-- use NoteFieldProxy to apply materials on a notefield.
-- this sets the proxy's target to P1's notefield as well
notefield = td.NoteFieldProxy:new(notefield, texturedMaterial, P1)
notefield:xyz(250, -60, 0)
scene:add(notefield)

-- add lights to the scene -------------------------------------

local light = td.PointLight:new(
	-- color, intensity, position
	td.color(1, 0.9, 0.8), 2, td.Vec3:new(0, -400, 600)
)
scene:addLight(light)

local light2 = td.PointLight:new(
	td.color(0.8, 0.8, 1), 1, td.Vec3:new(100, 400, -600)
)
scene:addLight(light2)

local ambientLight = td.AmbientLight:new(
	-- color, intensity
	td.color(0.8, 0.8, 1), 0.05
)
scene:addLight(ambientLight)

-- finalize the scene ------------------------------------------

-- this compiles all the materials' shaders and freezes many aspects of the
-- scene in place. for example, you should not add any more actors or lights
-- to the scene after this.
scene:finalize()

setdefault {
	-- you probably should set these mods if you have notefields in your scene
	100, 'zbuffer', 100, 'ztest', 100, 'receptorzbuffer',
	-- prevent back faces of arrows from becoming invisible
	300, 'arrowcull',
	-- some other cool mods
	100, 'drunkz', 20, 'orient', 100, 'twirl', 100, 'confusiony'
}

-- animate the scene during gameplay ---------------------------

perframe {0, 64, function(beat)
	-- rotate the camera in a circle around (0, 0, 0)
	local pos = td.Vec3:new(
		math.cos(beat/2)*900, -150, math.sin(beat/2)*900
	)
	camera:lookAt(pos, td.Vec3:new(0, 0, 0))

	-- change the cube's color over time
	redMaterial:update{
		color = td.color(1, 0, math.sin(beat*2)*0.5+0.5)
	}
end}