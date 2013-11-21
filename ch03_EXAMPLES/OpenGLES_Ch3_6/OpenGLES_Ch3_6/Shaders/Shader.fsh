//
//  Shader.fsh
//  
//

/////////////////////////////////////////////////////////////////
// UNIFORMS
/////////////////////////////////////////////////////////////////
uniform sampler2D uSampler0;
uniform sampler2D uSampler1;

/////////////////////////////////////////////////////////////////
// Varyings
/////////////////////////////////////////////////////////////////
varying lowp vec4 vColor;
varying lowp vec2 vTextureCoord0;
varying lowp vec2 vTextureCoord1;

void main()
{
   // Get the sampled colors from texture units 0 and 1.
   lowp vec4 color0 = texture2D(uSampler0, vTextureCoord0);
   lowp vec4 color1 = texture2D(uSampler1, vTextureCoord1);

   // Mix the two sampled colors using texColor1's alpha 
   // component and then multiply by the light color.
   gl_FragColor = mix(color0, color1, color1.a) * vColor;
}
