//
//  ParticleShader.fsh
//  
//

/////////////////////////////////////////////////////////////////
// UNIFORMS
/////////////////////////////////////////////////////////////////
uniform highp mat4      u_mvpMatrix;
uniform sampler2D       u_samplers2D[1];
uniform highp vec3      u_gravity;
uniform highp float     u_elapsedSeconds;

/////////////////////////////////////////////////////////////////
// Varyings
/////////////////////////////////////////////////////////////////
varying lowp float      v_particleOpacity;


void main()
{
   lowp vec4 textureColor = texture2D(u_samplers2D[0], 
      gl_PointCoord);
   textureColor.a = textureColor.a * v_particleOpacity;
   
   gl_FragColor = textureColor;
}
