//
//  ModelShader.vsh
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
uniform mat4      u_mvpMatrix;
uniform mat3      u_normalMatrix;
uniform sampler2D u_units[MAX_TEXTURES];
uniform vec4      u_globalAmbientColor;
uniform vec3      u_normalEyeDiffuseLightDirection;

/////////////////////////////////////////////////////////////////
// Varyings
/////////////////////////////////////////////////////////////////
varying vec2      v_texCoords[MAX_TEX_COORDS];
varying vec4      v_lightColor;


void main()
{
   vec3 normal = u_normalMatrix * a_normal;
   
   // Light
   normal = normalize(normal);
   float nDotL = max(
      dot(normal, u_normalEyeDiffuseLightDirection), 0.0);
   v_lightColor = 
      vec4(nDotL * vec3(0.7, 0.7, 0.7), 1.0) + 
      u_globalAmbientColor;
   
   // Texture coords
   v_texCoords[0] = a_texCoords0;
   
   gl_Position = u_mvpMatrix * vec4(a_position, 1.0); 
}
