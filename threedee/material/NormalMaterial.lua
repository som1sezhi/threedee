local class = require 'threedee.class'
local Material = require 'threedee.material.Material'

local VERT_SHADER = [[#version 120
attribute vec4 TextureMatrixScale;

varying vec3 normal;
varying vec2 textureCoord;
varying vec2 imageCoord;

uniform vec2 textureSize;
uniform vec2 imageSize;
uniform mat4 textureMatrix;
uniform mat4 modelMatrix;

// scene uniforms
uniform mat4 tdViewMatrix;
uniform mat4 tdProjMatrix;

void main() {
	normal = gl_NormalMatrix * gl_Normal * vec3(1.0, -1.0, 1.0);

	vec4 p = modelMatrix * gl_Vertex;
	gl_Position = tdProjMatrix * tdViewMatrix * p;

	gl_TexCoord[0] = (textureMatrix * gl_MultiTexCoord0 * TextureMatrixScale) + (gl_MultiTexCoord0 * (vec4(1)-TextureMatrixScale));
	textureCoord = ((textureMatrix * gl_MultiTexCoord0 * TextureMatrixScale) + (gl_MultiTexCoord0 * (vec4(1)-TextureMatrixScale))).xy;
	imageCoord = textureCoord * textureSize / imageSize;
}
]]

local FRAG_SHADER = [[#version 120
varying vec2 textureCoord;
varying vec3 normal;

uniform sampler2D sampler0;

void main() {
    vec3 nrm = normalize(normal) * vec3(1., -1., 1.);
    // if (dot(nrm, cameraPos - worldPos) < 0.0) nrm = -nrm;
    float alpha = texture2D(sampler0, textureCoord).a;
    gl_FragColor = vec4(nrm * 0.5 + 0.5, step(0.001, alpha));
}
]]

---@class NormalMaterial: Material
local NormalMaterial = class('NormalMaterial', Material)

function NormalMaterial:new(programOrActor)
    return Material.new(self, programOrActor)
end

function NormalMaterial:compile(scene)
    self.program:compile(VERT_SHADER, FRAG_SHADER)
end

function NormalMaterial:onFrameStart(scene)
    self.program:uniform3fv('cameraPos', scene.camera.position)
    self.program:uniform3fv('lightPos', scene.lightPos)
    self.program:uniformMatrix4fv('tdViewMatrix', scene.camera.viewMatrix)
    self.program:uniformMatrix4fv('tdProjMatrix', scene.camera.projMatrix)
    self.program:uniform1f('nearDist', scene.camera.nearDist)
    self.program:uniform1f('farDist', scene.camera.farDist)
end

return NormalMaterial