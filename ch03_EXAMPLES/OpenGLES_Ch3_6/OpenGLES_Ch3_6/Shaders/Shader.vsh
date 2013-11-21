//
//  Shader.vsh
//  
//

/////////////////////////////////////////////////////////////////
// VERTEX ATTRIBUTES
/////////////////////////////////////////////////////////////////
attribute vec4 aPosition;
attribute vec3 aNormal;
attribute vec2 aTextureCoord0;
attribute vec2 aTextureCoord1;

/////////////////////////////////////////////////////////////////
// Varyings
/////////////////////////////////////////////////////////////////
varying lowp vec4 vColor;
varying lowp vec2 vTextureCoord0;
varying lowp vec2 vTextureCoord1;

/////////////////////////////////////////////////////////////////
// UNIFORMS
/////////////////////////////////////////////////////////////////
uniform mat4 uModelViewProjectionMatrix;
uniform mat3 uNormalMatrix;

void main()
{
   // Gather information needed to calculate light color
   vec3 eyeNormal = normalize(uNormalMatrix * aNormal);
   vec3 lightPosition = vec3(0.0, 0.0, 1.0);
   vec4 diffuseColor = vec4(0.7, 0.7, 0.7, 1.0);

   // Calculate the light contribution to final fragment color
   float nDotVP = max(0.0, dot(eyeNormal, lightPosition));                 
   vColor = vec4((diffuseColor * nDotVP).xyz, diffuseColor.a);

   // Pass the two sets of texture coordinates to the fragment
   // shader unmodified.
   vTextureCoord0 = aTextureCoord0.st;
   vTextureCoord1 = aTextureCoord1.st;
     
   // Transform the incoming vertex position by the combined 
   // model-view-projection matrix to produce a fragment 
   // position in the Color Render Buffer
   gl_Position = uModelViewProjectionMatrix * aPosition;
}
