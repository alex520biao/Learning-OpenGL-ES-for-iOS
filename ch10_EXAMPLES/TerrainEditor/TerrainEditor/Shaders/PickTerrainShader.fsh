//
//  PickTerrainShader.fsh
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
uniform vec2      u_dimensionFactors;
uniform float     u_modelIndex;
uniform sampler2D u_units[MAX_TEXTURES];

/////////////////////////////////////////////////////////////////
// Varyings
/////////////////////////////////////////////////////////////////
varying vec4      v_color;
varying vec2      v_texCoords[MAX_TEX_COORDS];


void main()
{  
   if(0.0 < v_color.b) // Model index has been set
   {
      vec4 modelColor = texture2D(u_units[0], v_texCoords[0]);
      
      if (modelColor.a < 0.2)
      { // Discard mostly transparent frgaments to avoid depth
        // buffer write and artifcats caused by linear texel 
        // sampling when mipmaps are created.
        discard;
      }
   }
   
   gl_FragColor = v_color;
}
