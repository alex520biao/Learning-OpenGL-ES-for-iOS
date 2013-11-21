//
//  AGLKTextureMatrix2PointLightShader.vsh
//  
//

/////////////////////////////////////////////////////////////////
// VERTEX ATTRIBUTES
/////////////////////////////////////////////////////////////////
attribute vec3 a_position;
attribute vec3 a_normal;
attribute vec2 a_texCoord0;
attribute vec2 a_texCoord1;

/////////////////////////////////////////////////////////////////
// TEXTURE
/////////////////////////////////////////////////////////////////
#define MAX_TEXTURES    2
#define MAX_TEX_COORDS  2

/////////////////////////////////////////////////////////////////
// UNIFORMS
/////////////////////////////////////////////////////////////////
uniform highp mat4      u_modelviewMatrix;
uniform highp mat4      u_mvpMatrix;
uniform highp mat3      u_normalMatrix;
uniform highp mat4      u_tex0Matrix;
uniform highp mat4      u_tex1Matrix;
uniform sampler2D       u_unit2d[MAX_TEXTURES];
uniform lowp  float     u_tex0Enabled;
uniform lowp  float     u_tex1Enabled;
uniform lowp  vec4      u_globalAmbient;
uniform highp vec3      u_light0EyePos;
uniform lowp  vec3      u_light0NormalEyeDirection;
uniform lowp  vec4      u_light0Diffuse;
uniform highp float     u_light0Cutoff;
uniform highp float     u_light0Exponent;
uniform highp vec3      u_light1EyePos;
uniform lowp  vec3      u_light1NormalEyeDirection;
uniform lowp  vec4      u_light1Diffuse;
uniform highp float     u_light1Cutoff;
uniform highp float     u_light1Exponent;
uniform highp vec3      u_light2EyePos;
uniform lowp  vec4      u_light2Diffuse;

/////////////////////////////////////////////////////////////////
// Varyings
/////////////////////////////////////////////////////////////////
varying highp vec2      v_texCoord[MAX_TEX_COORDS];
varying lowp vec3       v_normal;
varying lowp vec3       v_vertexToLight0;
varying lowp vec4       v_diffuseColor0;
varying lowp vec3       v_vertexToLight1;
varying lowp vec4       v_diffuseColor1;
varying lowp vec4       v_diffuseColor2;


void main()
{
   // Texture
   v_texCoord[0] = a_texCoord0;
   v_texCoord[1] = a_texCoord1;

   // Normalized normal
   v_normal = normalize(u_normalMatrix * a_normal).xyz;
    
   // Light0
   highp vec3 eyePos = (u_modelviewMatrix * vec4(a_position, 1)).xyz;
   v_vertexToLight0 = normalize(u_light0EyePos - eyePos);
   v_diffuseColor0 = u_light0Diffuse;

   // Light1
   eyePos = (u_modelviewMatrix * vec4(a_position, 1)).xyz;
   v_vertexToLight1 = normalize(u_light1EyePos - eyePos);
   v_diffuseColor1 = u_light1Diffuse;

   // Light2 (always directional: u_light2EyePos is really a direction)
   lowp float nDotL = max(dot(v_normal, normalize(u_light2EyePos.xyz)), 0.0);
   v_diffuseColor2 = nDotL * u_light2Diffuse;

   gl_Position = u_mvpMatrix * vec4(a_position, 1);
}
