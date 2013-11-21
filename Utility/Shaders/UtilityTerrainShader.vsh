//
//  UtilityTerrainShader.vsh
//  
//

/////////////////////////////////////////////////////////////////
// VERTEX ATTRIBUTES
/////////////////////////////////////////////////////////////////
attribute vec3 a_position;

/////////////////////////////////////////////////////////////////
// TEXTURE
/////////////////////////////////////////////////////////////////
#define MAX_TEXTURES    5
#define MAX_TEX_COORDS  5

/////////////////////////////////////////////////////////////////
// UNIFORMS
/////////////////////////////////////////////////////////////////
uniform highp mat4      u_mvpMatrix;
uniform highp mat3      u_texMatrices[MAX_TEXTURES];
uniform sampler2D       u_units[MAX_TEXTURES];
uniform lowp vec4       u_globalAmbientColor;

/////////////////////////////////////////////////////////////////
// Varyings
/////////////////////////////////////////////////////////////////
varying highp vec2      v_texCoords[MAX_TEX_COORDS];


void main()
{
   vec3 coords = u_texMatrices[0] * a_position; 
   v_texCoords[0] = vec2(coords.x, coords.z); 
   coords = u_texMatrices[1] * a_position; 
   v_texCoords[1] = vec2(coords.x, coords.z); 
   coords = u_texMatrices[2] * a_position; 
   v_texCoords[2] = vec2(coords.x, coords.z); 
   coords = u_texMatrices[3] * a_position; 
   v_texCoords[3] = vec2(coords.x, coords.z); 
   coords = u_texMatrices[4] * a_position; 
   v_texCoords[4] = vec2(coords.x, coords.z);
       
   gl_Position = u_mvpMatrix * vec4(a_position, 1.0); 
}
