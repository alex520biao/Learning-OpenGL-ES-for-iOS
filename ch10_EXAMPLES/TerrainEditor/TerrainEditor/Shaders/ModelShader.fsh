//
//  ModelShader.fsh
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
   vec4 color = texture2D(u_units[0], v_texCoords[0]);

   if (color.a < 0.2)
   { // Discard mostly transparent frgaments to avoid depth
     // buffer write and artifcats caused by linear texel 
     // sampling when mipmaps are created.
     discard;
   }
    
   gl_FragColor = color;
}
