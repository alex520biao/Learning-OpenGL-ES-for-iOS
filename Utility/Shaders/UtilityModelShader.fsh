//
//  UtilityModelShader.fsh
//  
//

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
   lowp vec4 color = texture2D(u_units[0], v_texCoords[0]);
   if (color.a < 0.2)
   {  // discard nearly transparent fragments
      discard;
   }
    
   gl_FragColor = color * v_lightColor;
}
