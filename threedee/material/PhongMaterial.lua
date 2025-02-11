local Color = require 'threedee.math.Color'
local class = require 'threedee.class'
local Material = require 'threedee.material.Material'

local VERT_SHADER = [[#version 120
attribute vec4 TextureMatrixScale;

varying vec3 position;
varying vec3 normal;
varying vec4 color;
varying vec2 textureCoord;
varying vec2 imageCoord;

varying vec3 worldPos;
varying vec4 lightSpacePos;

uniform vec2 textureSize;
uniform vec2 imageSize;
uniform mat4 textureMatrix;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;

// scene uniforms
uniform mat4 tdViewMatrix;
uniform mat4 tdProjMatrix;
uniform mat4 lightViewMatrix;
uniform mat4 lightProjMatrix;

void main() {
	normal = gl_NormalMatrix * gl_Normal * vec3(1.0, -1.0, 1.0);

	vec4 p = modelMatrix * gl_Vertex;
	gl_Position = tdProjMatrix * tdViewMatrix * p;
	position = gl_Vertex.xyz;
	worldPos = p.xyz;
    lightSpacePos = lightProjMatrix * lightViewMatrix * p;

	gl_TexCoord[0] = (textureMatrix * gl_MultiTexCoord0 * TextureMatrixScale) + (gl_MultiTexCoord0 * (vec4(1)-TextureMatrixScale));
	textureCoord = ((textureMatrix * gl_MultiTexCoord0 * TextureMatrixScale) + (gl_MultiTexCoord0 * (vec4(1)-TextureMatrixScale))).xy;
	imageCoord = textureCoord * textureSize / imageSize;
	//gl_FrontColor = gl_Color;
	color = gl_Color;
}
]]

local FRAG_SHADER = [[#version 120
varying vec3 position;
varying vec3 normal;
varying vec4 color;
varying vec2 textureCoord;

varying vec3 worldPos;
varying vec4 lightSpacePos;

#ifdef USE_DIFFUSE_MAP
    #ifdef USE_DIFFUSE_MAP_SAMPLER0
        uniform sampler2D sampler0;
        #define diffuseMap sampler0
    #else
        uniform sampler2D diffuseMap;
    #endif
#endif

uniform float asdf;

// material uniforms
uniform vec3 diffuse;
uniform vec3 specular;
uniform vec3 emissive;
uniform float shininess;

// scene uniforms
uniform vec3 lightPos;
uniform vec3 cameraPos;
uniform bool doShadows;
uniform sampler2D shadowMap;
uniform vec2 shadowMapTextureSize;
uniform vec2 shadowMapImageSize;
uniform float lightNearDist;
uniform float lightFarDist;

float linearizeDepth(float depthNDC, float near, float far) {
    return (2.0 * near * far) / (far + near - depthNDC * (far - near));
}

vec2 img2texShadowMap( vec2 v ) {
    //vec2 uv = v / shadowMapTextureSize * shadowMapImageSize;
    // nearest neighbour
    return (floor(v * shadowMapImageSize) + 0.5) / shadowMapTextureSize;
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

float perspectiveDepthToViewZ( const in float depth, const in float near, const in float far ) {
	// maps perspective depth in [ 0, 1 ] to viewZ
	return ( near * far ) / ( ( far - near ) * depth - far );
}

float round(float v) { return floor(v + 0.5); }
float invlerp(float a, float b, float v) { return (v - a) / (b - a); }

#define OLD
#ifdef OLD
float calcShadow(vec4 fragLightSpacePos) {
    vec3 projCoord = fragLightSpacePos.xyz / fragLightSpacePos.w;

    if (projCoord.z < -1.0 || 1.0 < projCoord.z)
        return 0.0;

    vec2 texelSize = 1. / shadowMapTextureSize;
    vec2 corner1 = 0.5 * texelSize;
    vec2 corner2 = shadowMapImageSize / shadowMapTextureSize - corner1;    
    vec2 baseUV = img2texShadowMap(projCoord.xy * 0.5 + 0.5);
    // no shadows outside the shadowmap's frame
    if (any(lessThan(baseUV, corner1)) || any(greaterThan(baseUV, corner2)))
        return 0.0;

    float currentDepth = linearizeDepth(projCoord.z, lightNearDist, lightFarDist) / lightFarDist;
    // currentDepth -= max(0.01 * (1.0 - dot(nrm, light)), 0.002);
    //currentDepth = invlerp(lightNearDist, lightFarDist, currentDepth);
    currentDepth -= 0.003;

    float shadow = 0.0;
    float pcfDepth = 0.0;
    vec3 n = vec3(0.0);
    for (float x = -1.; x <= 1.; x += 1.) {
        for (float y = -1.; y <= 1.; y += 1.) {
            vec2 uv = baseUV + vec2(x, y) * texelSize;
            // we still need this clamp here because of PCF neighbor sampling
            uv = clamp(uv, corner1, corner2);
            
            pcfDepth = unpackRGBToDepth(texture2D(shadowMap, uv).rgb);
            //pcfDepth = texture2D(shadowMap, uv).r;
            n = texture2D(shadowMap, uv).rgb;
            shadow += currentDepth > pcfDepth ? 1.0 : 0.0;
        }
    }
    shadow /= 9.0;
    //gl_FragColor = vec4(n, 1.0);
    //return;
    // shadow = texture2D(shadowMap, img2texShadowMap(projCoord.xy)).r;
    return shadow;
}
#else
//#define PCF_3X3
float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
float calcShadow(vec4 fragLightSpacePos) {
    vec3 projCoord = fragLightSpacePos.xyz / fragLightSpacePos.w;

    if (projCoord.z < -1.0 || 1.0 < projCoord.z)
        return 0.0;

    vec2 texelSize = 1. / shadowMapTextureSize;
    vec2 corner1 = 0.5 * texelSize;
    vec2 corner2 = shadowMapImageSize / shadowMapTextureSize - corner1;
    projCoord.xy = projCoord.xy * 0.5 + 0.5;
    #ifdef PCF_3X3
        vec2 baseUV = img2texShadowMap(projCoord.xy);
    #else
        vec2 baseUV = (floor(projCoord.xy * shadowMapImageSize - 0.5) + 0.5) / shadowMapTextureSize;
    #endif
    // no shadows outside the shadowmap's frame
    if (any(lessThan(baseUV, corner1)) || any(greaterThan(baseUV, corner2)))
        return 0.0;

    float currentDepth = linearizeDepth(projCoord.z, lightNearDist, lightFarDist) / lightFarDist;
    // currentDepth -= max(0.01 * (1.0 - dot(nrm, light)), 0.002);
    //currentDepth = invlerp(lightNearDist, lightFarDist, currentDepth);
    currentDepth -= 0.003;

    #ifdef PCF_3X3
        #define IS_SHADOW_SIZE 9
        #define SHADOW_FILTER_UPPER_BOUND 1.0
        #define SHADOW_FILTER_SIZE 2
        #define NUM_PCF_RESULTS 4.0
    #else
        #define IS_SHADOW_SIZE 16
        #define SHADOW_FILTER_UPPER_BOUND 2.0
        #define SHADOW_FILTER_SIZE 3
        #define NUM_PCF_RESULTS 9.0
    #endif

    float isShadow[IS_SHADOW_SIZE];
    int i = 0;
    for (float y = -1.0; y <= SHADOW_FILTER_UPPER_BOUND; y += 1.0) {
        for (float x = -1.0; x <= SHADOW_FILTER_UPPER_BOUND; x += 1.0) {
            vec2 uv = baseUV + vec2(x, y) * texelSize;
            // we still need this clamp here because of PCF neighbor sampling
            uv = clamp(uv, corner1, corner2);
            
            float pcfDepth = unpackRGBToDepth(texture2D(shadowMap, uv).rgb);
            //pcfDepth = texture2D(shadowMap, uv).r;
            isShadow[i] = currentDepth > pcfDepth ? 1.0 : 0.0;
            i++;
        }
    }

    #ifdef PCF_3X3
        vec2 uvf = fract(projCoord.xy * shadowMapImageSize);
    #else
        vec2 uvf = fract(projCoord.xy * shadowMapImageSize - 0.5);
    #endif
    float shadow = 0.0;
    #define pcfBilinear(a, b, c, d) (mix(mix(isShadow[a], isShadow[b], uvf.x), mix(isShadow[c], isShadow[d], uvf.x), uvf.y))
    for (int i = 0; i < SHADOW_FILTER_SIZE; i++) {
        for (int j = 0; j < SHADOW_FILTER_SIZE; j++) {
            shadow += pcfBilinear(SHADOW_FILTER_SIZE*i+j, 1+SHADOW_FILTER_SIZE*i+j, SHADOW_FILTER_SIZE*(i+1)+j, 1+SHADOW_FILTER_SIZE*(i+1)+j);
        }
    }
    shadow /= NUM_PCF_RESULTS;
    //gl_FragColor = vec4(n, 1.0);
    //return;
    // shadow = texture2D(shadowMap, img2texShadowMap(projCoord.xy)).r;
    return shadow;
}
#endif

// ------------------------
// code sourced from "Followup: Normal Mapping Without Precomputed Tangents"
// http://www.thetenthplanet.de/archives/1180

uniform sampler2D normalMap;

mat3 cotangentFrame(vec3 N, vec3 p, vec2 uv) {
    // get edge vectors of the pixel triangle
    vec3 dp1 = dFdx(p);
    vec3 dp2 = dFdy(p);
    vec2 duv1 = dFdx(uv);
    vec2 duv2 = dFdy(uv);
    // solve the linear system
    vec3 dp2perp = cross(dp2, N);
    vec3 dp1perp = cross(N, dp1);
    vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
    vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;
    // construct a scale-invariant frame
    float invmax = inversesqrt(max(dot(T,T), dot(B,B)));
    return mat3(T * invmax, B * invmax, N);
}

vec3 perturbNormal(vec3 N, vec3 V, vec2 texCoord) {
    vec3 map = texture2D(normalMap, (texCoord)).xyz;
    map = map * 255./127. - 128./127.;
    map.y *= -1.;
    //map.xy *= 1.5;
    map = normalize(map);
    mat3 TBN = cotangentFrame(N, -V, texCoord);
    //return normalize(TBN * vec3(0.,0.,1.));
    return normalize(TBN * map);
}

void main() {
    vec3 diffuseCol = diffuse * pow(color.rgb, vec3(2.2));
    float alpha = color.a;
    #ifdef USE_DIFFUSE_MAP
        vec4 diffuseMapSample = texture2D(sampler0, textureCoord);
        diffuseCol *= pow(diffuseMapSample.rgb, vec3(2.2));
        alpha *= diffuseMapSample.a;
    #endif

    vec3 nrm = normalize(normal) * vec3(1., -1., 1.);
    if (dot(nrm, cameraPos - worldPos) < 0.0) nrm = -nrm;

    vec3 light = lightPos - worldPos;
    float lightDist = length(light);
    light /= lightDist;
    vec3 V = (cameraPos - worldPos);
    #ifdef USE_NORMAL_MAP
        nrm = perturbNormal(nrm, V, textureCoord);
    #endif
    V = normalize(V);
    float diffuseFac = max(0., dot(nrm, light));
    float specularFac = 0.;
    if (diffuseFac > 0.) {
        vec3 R = reflect(-light, nrm);
        specularFac = pow(max(0., dot(R, V)), shininess);
    }

    float attenuation = 1. / (1. + 0.000002 * lightDist * lightDist);

    if (doShadows) {
        float shadow = calcShadow(lightSpacePos);
        attenuation *= (1.0 - shadow);
    }

    const vec3 ambient = vec3(0.04);

    vec3 col = emissive;
    col += (attenuation * diffuseFac + ambient) * diffuseCol + specular * specularFac * attenuation;

    col = pow(col, vec3(.4545));
    
    //col = vec3(LinearizeDepth(gl_FragCoord.z)/farDist);
    //col = nrm * 0.5 + 0.5;
    //col = gl_FrontFacing ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
    gl_FragColor = vec4(col, alpha * asdf);
}
]]

---@class PhongMaterial: Material
---@field diffuse Color diffuse color
---@field diffuseMap? RageTexture|'sampler0'
---@field specular Color specular color
---@field emissive Color emissive/ambient color
---@field shininess number sharpness of highlight
---@field normalMap? RageTexture
local PhongMaterial = class('PhongMaterial', Material)

function PhongMaterial:new(programOrActor)
    local o = Material.new(self, programOrActor)
    o.diffuse = Color:new(1, 1, 1)
    o.specular = Color:new(1, 1, 1)
    o.emissive = Color:new(0, 0, 0)
    o.shininess = 30
    return o
end

function PhongMaterial:compile(scene)
    self.program:compile(VERT_SHADER, FRAG_SHADER)
    self:_defineFlag('USE_DIFFUSE_MAP', self.diffuseMap)
    self:_defineFlag('USE_DIFFUSE_MAP_SAMPLER0', self.diffuseMap == 'sampler0')
    self:_defineFlag('USE_NORMAL_MAP', self.normalMap)
    self.program:compileImmediate()
end

function PhongMaterial:onFrameStart(scene)
    -- material uniforms
    self.program:uniform3fv('diffuse', self.diffuse)
    if self.diffuseMap and self.diffuseMap ~= 'sampler0' then
        local map = self.diffuseMap --[[@as RageTexture]]
        self.program:uniformTexture('diffuseMap', map)
        self.program:uniform2f('textureSize', map:GetTextureWidth(), map:GetTextureHeight())
        self.program:uniform2f('imageSize', map:GetImageWidth(), map:GetImageWidth())
    end
    self.program:uniform3fv('specular', self.specular)
    self.program:uniform3fv('emissive', self.emissive)
    self.program:uniform1f('shininess', self.shininess)
    if self.normalMap then
        self.program:uniformTexture('normalMap', self.normalMap)
        self.program:uniform2f('textureSize', self.normalMap:GetTextureWidth(), self.normalMap:GetTextureHeight())
        self.program:uniform2f('imageSize', self.normalMap:GetImageWidth(), self.normalMap:GetImageWidth())
    end

    -- scene uniforms
    self.program:uniform3fv('cameraPos', scene.camera.position)
    self.program:uniform3fv('lightPos', scene.lightPos)
    self.program:uniformMatrix4fv('tdViewMatrix', scene.camera.viewMatrix)
    self.program:uniformMatrix4fv('tdProjMatrix', scene.camera.projMatrix)
    self.program:uniform1i('doShadows', scene.doShadows and 1 or 0)
    if scene.doShadows then
        local sh = scene.shadowMap
        self.program:uniformTexture('shadowMap', sh)
        self.program:uniform2f('shadowMapTextureSize',
            sh:GetTextureWidth(), sh:GetTextureHeight()
        )
        self.program:uniform2f('shadowMapImageSize',
            sh:GetImageWidth(), sh:GetImageHeight()
        )
        self.program:uniformMatrix4fv('lightViewMatrix', scene.lightCamera.viewMatrix)
        self.program:uniformMatrix4fv('lightProjMatrix', scene.lightCamera.projMatrix)
        self.program:uniform1f('lightNearDist', scene.lightCamera.nearDist)
        self.program:uniform1f('lightFarDist', scene.lightCamera.farDist)
    end
    self.program:uniform1f('asdf', 1)
end

return PhongMaterial