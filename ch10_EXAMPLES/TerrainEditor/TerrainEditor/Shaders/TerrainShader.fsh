//
//  TerrainShader.fsh
//  
//

/////////////////////////////////////////////////////////////////
// TEXTURE
/////////////////////////////////////////////////////////////////
#define MAX_TEXTURES    6
#define MAX_TEX_COORDS  5

/////////////////////////////////////////////////////////////////
// UNIFORMS
/////////////////////////////////////////////////////////////////
uniform mat4      u_mvpMatrix;
uniform mat3      u_texMatrices[MAX_TEXTURES];
uniform mat4      u_toolTextureMatrix;
uniform sampler2D u_units[MAX_TEXTURES];
uniform vec4      u_globalAmbientColor;

/////////////////////////////////////////////////////////////////
// Varyings
/////////////////////////////////////////////////////////////////
varying vec2      v_texCoords[MAX_TEX_COORDS];
varying vec2      v_toolTexCoords;


void main()
{
   // Extract light color from w component of light and weight
   // texture
   vec4 lightAndWeights = texture2D(u_units[0], v_texCoords[0]);
   vec4 lightColor = u_globalAmbientColor + vec4(
      lightAndWeights.w, 
      lightAndWeights.w, 
      lightAndWeights.w, 
      1.0);
   
   // Extract texture mixing weights from light and weight
   // texture
   vec3 weights = vec3(
      lightAndWeights.x,
      lightAndWeights.y,
      lightAndWeights.z);
   
   // Blend the terrain textures using weights   
   vec4 textureColor0 = texture2D(u_units[1], v_texCoords[1]);
   vec4 textureColor1 = texture2D(u_units[2], v_texCoords[2]);
   vec4 textureColor2 = texture2D(u_units[3], v_texCoords[3]);
   vec4 textureColor3 = texture2D(u_units[4], v_texCoords[4]);
   vec4 textureColor = textureColor3;
   textureColor = mix(textureColor, textureColor0, weights.x);
   textureColor = mix(textureColor, textureColor1, weights.y); 
   textureColor = mix(textureColor, textureColor2, weights.z); 

   vec4 toolsTexture = texture2D(u_units[5], v_toolTexCoords);
   if(toolsTexture.a > 0.55)
   {  // don't blend tool texture if not nearly opaque
      textureColor = 
         mix(textureColor, toolsTexture, toolsTexture.a);
   }

   // Scale by light color
   vec4 color = lightColor * textureColor;
         
   // Final terrain color is always opaque
   color.a = 1.0;
    
   gl_FragColor = color;
}
