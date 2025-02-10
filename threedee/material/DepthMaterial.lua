local class = require 'threedee.class'
local Material = require 'threedee.material.Material'

local VERT_SHADER = [[#version 120
attribute vec4 TextureMatrixScale;

varying vec3 position;
varying vec2 textureCoord;
varying vec2 imageCoord;

varying float viewZ;

uniform vec2 textureSize;
uniform vec2 imageSize;
uniform mat4 textureMatrix;
uniform mat4 modelMatrix;

// scene uniforms
uniform mat4 tdViewMatrix;
uniform mat4 tdProjMatrix;

void main() {
	vec4 p = modelMatrix * gl_Vertex;
	gl_Position = tdProjMatrix * tdViewMatrix * p;
	viewZ = gl_Position.z;

	gl_TexCoord[0] = (textureMatrix * gl_MultiTexCoord0 * TextureMatrixScale) + (gl_MultiTexCoord0 * (vec4(1)-TextureMatrixScale));
	textureCoord = ((textureMatrix * gl_MultiTexCoord0 * TextureMatrixScale) + (gl_MultiTexCoord0 * (vec4(1)-TextureMatrixScale))).xy;
	imageCoord = textureCoord * textureSize / imageSize;
}
]]

local FRAG_SHADER = [[#version 120
varying vec2 textureCoord;

varying float viewZ;

uniform sampler2D sampler0;
uniform float nearDist;
uniform float farDist;

// https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping
// Given a depth value in [-1, 1], outputs the (negative of the) Z view space coord
// (values will be positive for positions in front of the camera)
float linearizeDepth(float depthNDC, float near, float far) {
    return (2.0 * near * far) / (far + near - depthNDC * (far - near));
}

const float PackUpscale = 256. / 255.; // fraction -> 0..1 (including 1)
const float UnpackDownscale = 255. / 256.; // 0..1 -> fraction (excluding 1)
const float ShiftRight8 = 1. / 256.;
const float Inv255 = 1. / 255.;

const vec4 PackFactors = vec4( 1.0, 256.0, 256.0 * 256.0, 256.0 * 256.0 * 256.0 );

const vec2 UnpackFactors2 = vec2( UnpackDownscale, 1.0 / PackFactors.g );
const vec3 UnpackFactors3 = vec3( UnpackDownscale / PackFactors.rg, 1.0 / PackFactors.b );
const vec4 UnpackFactors4 = vec4( UnpackDownscale / PackFactors.rgb, 1.0 / PackFactors.a );

float modf_(float f, out float i) {
    i = floor(f);
    return fract(f);
}

vec3 packDepthToRGB( const in float v ) {
	if( v <= 0.0 )
		return vec3( 0., 0., 0. );
	if( v >= 1.0 )
		return vec3( 1., 1., 1. );
	float vuf;
	float bf = modf_( v * PackFactors.b, vuf );
	float gf = modf_( vuf * ShiftRight8, vuf );
	// the 0.9999 tweak is unimportant, very tiny empirical improvement
	// return vec3( vuf * Inv255, gf * PackUpscale, bf * 0.9999 );
	return vec3( vuf * Inv255, gf * PackUpscale, bf );
}

vec2 packDepthToRG( const in float v ) {
	if( v <= 0.0 )
		return vec2( 0., 0. );
	if( v >= 1.0 )
		return vec2( 1., 1. );
	float vuf;
	float gf = modf_( v * 256., vuf );
	return vec2( vuf * Inv255, gf );
}

float unpackRGBToDepth( const in vec3 v ) {
	return dot( v, UnpackFactors3 );
}

float unpackRGToDepth( const in vec2 v ) {
	return v.r * UnpackFactors2.r + v.g * UnpackFactors2.g;
}

float round(float v) { return floor(v + 0.5); }

float invlerp(float a, float b, float v) { return (v - a) / (b - a); }

void main() {
	// As it turns out, when NotITG draws an actor, it calls DISPLAY->SetZBias(),
	// which calls glDepthRange() with a range of size 0.95 (e.g. with a bias of 0,
	// the depth range will be [0.05, 1]). Thus we can't trust gl_FragCoord.z to
	// hold the "true" depth value of the fragment, so we must calculate it ourselves.
	float z = viewZ * gl_FragCoord.w; // recall gl_FragCoord.w = 1 / gl_Position.w
    float depth = linearizeDepth(z, nearDist, farDist) / farDist;
	//depth = invlerp(nearDist, farDist, depth);

    float alpha = texture2D(sampler0, textureCoord).a;
    gl_FragColor = vec4(packDepthToRGB(depth), step(0.001, alpha));
    //gl_FragColor = vec4(packDepthToRGB(depth), alpha);
    //gl_FragColor = vec4(vec3(depth), step(0.001, alpha));
}
]]

---@class DepthMaterial: Material
local DepthMaterial = class('DepthMaterial', Material)

function DepthMaterial:new(programOrActor)
    return Material.new(self, programOrActor)
end

function DepthMaterial:compile(scene)
    self.program:compile(VERT_SHADER, FRAG_SHADER)
end

function DepthMaterial:onFrameStart(scene)
    self.program:uniform3fv('cameraPos', scene.camera.position)
    self.program:uniform3fv('lightPos', scene.lightPos)
    self.program:uniformMatrix4fv('tdViewMatrix', scene.camera.viewMatrix)
    self.program:uniformMatrix4fv('tdProjMatrix', scene.camera.projMatrix)
    self.program:uniform1f('nearDist', scene.camera.nearDist)
    self.program:uniform1f('farDist', scene.camera.farDist)
end

return DepthMaterial