//
//  UtilityModelShader.vsh
//  
//

/////////////////////////////////////////////////////////////////
// VERTEX ATTRIBUTES
/////////////////////////////////////////////////////////////////
attribute vec3 a_position;
attribute vec3 a_normal;
attribute vec2 a_texCoords0;

/////////////////////////////////////////////////////////////////
// TEXTURE
/////////////////////////////////////////////////////////////////
#define MAX_TEXTURES    1
#define MAX_TEX_COORDS  1

/////////////////////////////////////////////////////////////////
// UNIFORMS
/////////////////////////////////////////////////////////////////
uniform highp mat4      u_mvpMatrix;
uniform highp mat3      u_normalMatrix;
uniform sampler2D       u_units[MAX_TEXTURES];
uniform lowp  vec4      u_globalAmbient;
uniform highp vec3      u_diffuseLightDirection;
uniform highp vec4      u_diffuseLightColor;

/////////////////////////////////////////////////////////////////
// Varyings
/////////////////////////////////////////////////////////////////
varying highp vec2      v_texCoords[MAX_TEX_COORDS];
varying lowp vec4       v_lightColor;


void main()
{
   // Texture coords
   v_texCoords[0] = a_texCoords0;
   
   // Lighting
   lowp vec3 normal = normalize(u_normalMatrix * a_normal);
   lowp float nDotL = max(
      dot(normal, normalize(u_diffuseLightDirection)), 0.0);
   v_lightColor = (nDotL * u_diffuseLightColor) + 
      u_globalAmbient;
   
   gl_Position = u_mvpMatrix * vec4(a_position, 1.0); 
}
