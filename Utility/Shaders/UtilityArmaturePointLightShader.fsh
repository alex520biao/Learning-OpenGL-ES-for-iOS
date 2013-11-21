//
//  UtilityArmaturePointLightShader.fsh
//  
//

/////////////////////////////////////////////////////////////////
// TEXTURE
/////////////////////////////////////////////////////////////////
#define MAX_TEXTURES    (2)
#define MAX_TEX_COORDS  (2)

/////////////////////////////////////////////////////////////////
// INDEXED MATRICES FOR ARMATURE JOINTS
/////////////////////////////////////////////////////////////////
#define MAX_INDEXED_MATRICES  (16)

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
uniform highp vec3      u_light0Position;
uniform lowp  vec4      u_light0Diffuse;
uniform highp mat4      u_mvpJointMatrices[MAX_INDEXED_MATRICES];
uniform highp mat3      u_normalJointNormalMatrices[MAX_INDEXED_MATRICES];

/////////////////////////////////////////////////////////////////
// Varyings
/////////////////////////////////////////////////////////////////
varying highp vec2      v_texCoord[MAX_TEX_COORDS];
varying lowp vec4       v_lightColor;


void main()
{
   // Texture0 contribution to color
   lowp vec2 texCoords = v_texCoord[0];
   lowp vec4 texCoordVec4 = vec4(texCoords.s, texCoords.t, 0, 
      1.0);
   texCoordVec4 = u_tex0Matrix * texCoordVec4;
   texCoords = texCoordVec4.st;
   lowp vec4 texColor0 = texture2D(u_unit2d[0], texCoords);
   texColor0 = u_tex0Enabled * texColor0;
   
   // Texture1 contribution to color
   texCoords = v_texCoord[1];
   texCoordVec4 = vec4(texCoords.s, texCoords.t, 0, 1.0);
   texCoordVec4 = u_tex1Matrix * texCoordVec4;
   texCoords = texCoordVec4.st;
   lowp vec4 texColor1 = texture2D(u_unit2d[1], texCoords);
   texColor1 = u_tex1Enabled * texColor1;
   
   // Combined texture contribution to color
   lowp vec4 combinedTexColor;   
   combinedTexColor.rgb = (texColor0.rgb * (1.0 - texColor1.a)) + 
                  (texColor1.rgb * texColor1.a);
   combinedTexColor.rgb += (1.0 - max(u_tex0Enabled, 
      u_tex1Enabled)) * vec3(1, 1, 1);
   combinedTexColor.a = max(texColor0.a, texColor1.a);
   
   // Mix light and texture
   gl_FragColor.rgb = (v_lightColor.rgb + u_globalAmbient.rgb) * 
      combinedTexColor.rgb;
   
   gl_FragColor.a = combinedTexColor.a;
}
