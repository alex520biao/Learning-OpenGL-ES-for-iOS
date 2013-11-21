//
//  ParticleShader.vsh
//  
//

/////////////////////////////////////////////////////////////////
// VERTEX ATTRIBUTES
/////////////////////////////////////////////////////////////////
attribute vec3 a_emissionPosition;
attribute vec3 a_emissionVelocity;
attribute vec3 a_emissionForce;
attribute vec2 a_size;
attribute vec2 a_emissionAndDeathTimes;

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
   highp float elapsedTime = u_elapsedSeconds - 
      a_emissionAndDeathTimes.x;
      
   // Mass is assumed to be 1.0, so acceleration = force (a = f/m)
   // v = v0 + at : v is current velocity; v0 is initial velocity;
   //               a is acceleration; t is elapsed time
   highp vec3 velocity = a_emissionVelocity + 
      ((a_emissionForce + u_gravity) * elapsedTime);
      
   // s = s0 + 0.5 * (v0 + v) * t : s is current position; 
   //                              s0 is initial position;
   //                              v0 is initial velocity; 
   //                              v is current velocity;
   //                              t is elapsed time
   highp vec3 untransformedPosition = a_emissionPosition +
      0.5 * (a_emissionVelocity + velocity) * elapsedTime;   
      
   gl_Position = u_mvpMatrix * vec4(untransformedPosition, 1.0);
   gl_PointSize = a_size.x / gl_Position.w;
   
   // if emission life > elapsed time then non-zero with maximum
   // opacity of 1.0; otherwise 0.0. Fades over a_size.y seconds
   v_particleOpacity = max(0.0, min(1.0, 
      (a_emissionAndDeathTimes.y - u_elapsedSeconds) / 
      max(a_size.y, 0.00001)));
}
