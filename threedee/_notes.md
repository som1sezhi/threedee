## On Coordinate Systems

(Note: "forwards" means away from the viewer, "backwards" means towards the viewer.)

NotITG uses a left-handed, Y-down coordinate system for positioning actors (+X right, +Y down, +Z backwards).

However, for `Model` actors specifically, it flips the Y-axis (this is applied via the model matrix). Therefore, in model space, +Y points up. For models to display as expected in NotITG, they should be exported such that the forward axis is -Z and the up axis is +Y.

OpenGL, by convention, is a right-handed, Y-up system (+X right, +Y up, +Z backwards), except for clip space/normalized device coordinates, where +Z points forward instead (making it a left-handed system).

To convert from NotITG's Y-down system to the Y-up system that OpenGL expects, NotITG flips the Y-axis using the projection matrix. This is done by specifying the bottom coordinate of the view frustum to have a positive/larger value than the top coordinate, which is the opposite of a conventional OpenGL app. Note that this is only done when converting from view to clip space, so the world and view spaces should be considered to be Y-down coordinate spaces.