//
//  UtilityTerrainShader.fsh
//  
//

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
   // Extract light color from w component of light and weight
   // texture
   lowp vec4 lightAndWeights = 
      texture2D(u_units[0], v_texCoords[0]);
   lowp vec4 lightColor = u_globalAmbientColor + lowp vec4(
      lightAndWeights.w, 
      lightAndWeights.w, 
      lightAndWeights.w, 
      1.0);
   
   // Extract texture mixing weights from light and weight
   // texture
   lowp vec3 weights = lowp vec3(
      lightAndWeights.x,
      lightAndWeights.y,
      lightAndWeights.z);
      
   // Blend the terrain textures using weights   
   lowp vec4 textureColor0 = texture2D(u_units[1], v_texCoords[1]);
   lowp vec4 textureColor1 = texture2D(u_units[2], v_texCoords[2]);
   lowp vec4 textureColor2 = texture2D(u_units[3], v_texCoords[3]);
   lowp vec4 textureColor3 = texture2D(u_units[4], v_texCoords[4]);
   lowp vec4 textureColor = textureColor3;
   textureColor = mix(textureColor, textureColor0, weights.x);
   textureColor = mix(textureColor, textureColor1, weights.y); 
   textureColor = mix(textureColor, textureColor2, weights.z); 
      
   // Scale by light color
   lowp vec4 color = lightColor * textureColor;

   // Final terrain color is always opaque
   color.a = 1.0;
    
   gl_FragColor = color;
}
