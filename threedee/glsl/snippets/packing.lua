--[[
Much of this code was taken from three.js, licensed under the MIT License

Copyright © 2010-2025 three.js authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]

return {
	snippet = [[
// https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping
// Given a depth value in NDC ([-1, 1]), outputs the (negative of the) Z view space coord
// (values will be positive for positions in front of the camera)
float linearizeDepth(float depthNDC, float near, float far) {
    return (2.0 * near * far) / (far + near - depthNDC * (far - near));
}

const float PackUpscale = 256. / 255.; // fraction -> 0..1 (including 1)
const float UnpackDownscale = 255. / 256.; // 0..1 -> fraction (excluding 1)
const float ShiftRight8 = 1. / 256.;
const float Inv255 = 1. / 255.;

const vec3 PackFactors = vec3(1.0, 256.0, 256.0 * 256.0);

const vec2 UnpackFactors2 = vec2(UnpackDownscale, 1.0 / PackFactors.g);
const vec3 UnpackFactors3 = vec3(UnpackDownscale / PackFactors.rg, 1.0 / PackFactors.b);

vec3 packDepthToRGB(const in float v) {
	if (v <= 0.0)
		return vec3(0., 0., 0.);
	if (v >= 1.0)
		return vec3(1., 1., 1.);
	float vuf;
	float bf = modf_(v * PackFactors.b, vuf);
	float gf = modf_(vuf * ShiftRight8, vuf);
	// the 0.9999 tweak is unimportant, very tiny empirical improvement
	// return vec3(vuf * Inv255, gf * PackUpscale, bf * 0.9999);
	return vec3(vuf * Inv255, gf * PackUpscale, bf);
}

vec2 packDepthToRG(const in float v) {
	if (v <= 0.0)
		return vec2(0., 0.);
	if (v >= 1.0)
		return vec2(1., 1.);
	float vuf;
	float gf = modf_(v * 256., vuf);
	return vec2(vuf * Inv255, gf);
}

float unpackRGBToDepth(const in vec3 v) {
	return dot(v, UnpackFactors3);
}

float unpackRGToDepth(const in vec2 v) {
	return v.r * UnpackFactors2.r + v.g * UnpackFactors2.g;
}
]],
	deps = {'utils'}
}