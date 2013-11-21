//
//  AGLKTextureRotationBaseEffect.m
// 
//

#import "AGLKTextureTransformBaseEffect.h"


/////////////////////////////////////////////////////////////////
// GLSL program uniform indices.
enum
{
   AGLKModelviewMatrix,
   AGLKMVPMatrix,
   AGLKNormalMatrix,
   AGLKTex0Matrix,
   AGLKTex1Matrix,
   AGLKSamplers,
   AGLKTex0Enabled,
   AGLKTex1Enabled,
   AGLKGlobalAmbient,
   AGLKLight0Pos,
   AGLKLight0Direction,
   AGLKLight0Diffuse,
   AGLKLight0Cutoff,
   AGLKLight0Exponent,
   AGLKLight1Pos,
   AGLKLight1Direction,
   AGLKLight1Diffuse,
   AGLKLight1Cutoff,
   AGLKLight1Exponent,
   AGLKLight2Pos,
   AGLKLight2Diffuse,
   AGLKNumUniforms
};


@interface AGLKTextureTransformBaseEffect ()
{
   GLuint _program;
   GLint _uniforms[AGLKNumUniforms];
}

@property (nonatomic, assign) GLKVector3 light0EyePosition;
@property (nonatomic, assign) GLKVector3 light0EyeDirection;
@property (nonatomic, assign) GLKVector3 light1EyePosition;
@property (nonatomic, assign) GLKVector3 light1EyeDirection;
@property (nonatomic, assign) GLKVector3 light2EyePosition;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader 
   type:(GLenum)type 
   file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end


@implementation AGLKTextureTransformBaseEffect

@synthesize textureMatrix2d0;
@synthesize textureMatrix2d1;
@synthesize light0EyePosition;
@synthesize light0EyeDirection;
@synthesize light1EyePosition;
@synthesize light1EyeDirection;
@synthesize light2EyePosition;


/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)init
{
   if(nil != (self = [super init]))
   {
      textureMatrix2d0 = GLKMatrix4Identity;
      textureMatrix2d1 = GLKMatrix4Identity;
      self.texture2d0.enabled = GL_FALSE;
      self.texture2d1.enabled = GL_FALSE;
      self.material.ambientColor = 
         GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
      self.lightModelAmbientColor = 
         GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
      self.light0.enabled = GL_FALSE;
      self.light1.enabled = GL_FALSE;
      self.light2.enabled = GL_FALSE;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// This method is an alternative to GLKBaseEffect's 
// -prepareToDraw method. Call -prepareToDraw to use inherited
// Shading Language programs and capabilities. Use this method
// to benefit from texture matrix additions provided by this
// class as well as per-pixel light calculations. Note: lighting
// via this method has constraints that may not apply to the
// inherited implementation. For example, with this method, 
// light2 must be directional, and specular components of lights
// are ignored.
- (void)prepareToDrawMultitextures
{
   if(0 == _program)
   {
      [self loadShaders];
   }
   
   if(0 != _program)
   {
      glUseProgram(_program);
      
      // Local storage for texture sampler IDs
      const GLuint   samplerIDs[2] = {0, 1};
      
      // Pre-calculate the mvpMatrix
      GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(
         self.transform.projectionMatrix, 
         self.transform.modelviewMatrix);
      
      // Standard matrices
      glUniformMatrix4fv(_uniforms[AGLKModelviewMatrix], 1, 0, 
         self.transform.modelviewMatrix.m);
      glUniformMatrix4fv(_uniforms[AGLKMVPMatrix], 1, 0, 
         modelViewProjectionMatrix.m);
      glUniformMatrix3fv(_uniforms[AGLKNormalMatrix], 1, 0, 
         self.transform.normalMatrix.m);      
      glUniformMatrix4fv(_uniforms[AGLKTex0Matrix], 1, 0, 
         self.textureMatrix2d0.m);
      glUniformMatrix4fv(_uniforms[AGLKTex1Matrix], 1, 0, 
         self.textureMatrix2d1.m);
         
      // Two texture samplers
      glUniform1iv(_uniforms[AGLKSamplers], 2, 
         (const GLint *)samplerIDs); 

      // Pre-calculate the global ambient light contribution
      // using only uniform parameters rather than send all
      // the separate uniforms to the vertex shader
      GLKVector4 globalAmbient = GLKVector4Multiply(
         self.lightModelAmbientColor, 
         self.material.ambientColor);
      if(self.light0.enabled)
      {
         globalAmbient = GLKVector4Add(globalAmbient,
            GLKVector4Multiply(
               self.light0.ambientColor, 
               self.material.ambientColor));
      }
      if(self.light1.enabled)
      {
         globalAmbient = GLKVector4Add(globalAmbient,
            GLKVector4Multiply(
               self.light1.ambientColor, 
               self.material.ambientColor));
      }
      if(self.light2.enabled)
      {
         globalAmbient = GLKVector4Add(globalAmbient,
            GLKVector4Multiply(
               self.light2.ambientColor, 
               self.material.ambientColor));
      }
      glUniform4fv(_uniforms[AGLKGlobalAmbient], 1, 
         globalAmbient.v);
         
      // Scale factors for texture contribution
      glUniform1f(_uniforms[AGLKTex0Enabled], 
         self.texture2d0.enabled ? 1.0 : 0.0);
      glUniform1f(_uniforms[AGLKTex1Enabled], 
         self.texture2d1.enabled ? 1.0 : 0.0);
      
      // Light0
      // Material diffuse interaction with light is baked in
      // so there is no reason to send material diffuse
      // color to shaders
      if(self.light0.enabled)
      {
         glUniform3fv(_uniforms[AGLKLight0Pos], 1, 
            self.light0EyePosition.v);
         glUniform3fv(_uniforms[AGLKLight0Direction], 1, 
            light0EyeDirection.v);
         glUniform4fv(_uniforms[AGLKLight0Diffuse], 1, 
            GLKVector4Multiply(self.light0.diffuseColor,
               self.material.diffuseColor).v);
         glUniform1f(_uniforms[AGLKLight0Cutoff], 
            GLKMathDegreesToRadians(self.light0.spotCutoff));
         glUniform1f(_uniforms[AGLKLight0Exponent], 
            self.light0.spotExponent);
      }
      else
      {
         glUniform4fv(_uniforms[AGLKLight0Diffuse], 1, 
            GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f).v);
      }
      
      // Light1
      // Material diffuse interaction with light is baked in
      // so there is no reason to send material diffuse
      // color to shaders
      if(self.light1.enabled)
      {
         glUniform3fv(_uniforms[AGLKLight1Pos], 1, 
            self.light1EyePosition.v);
         glUniform3fv(_uniforms[AGLKLight1Direction], 1, 
            light1EyeDirection.v);
         glUniform4fv(_uniforms[AGLKLight1Diffuse], 1, 
            GLKVector4Multiply(self.light1.diffuseColor,
               self.material.diffuseColor).v);
         glUniform1f(_uniforms[AGLKLight1Cutoff], 
            GLKMathDegreesToRadians(self.light1.spotCutoff));
         glUniform1f(_uniforms[AGLKLight1Exponent], 
            self.light1.spotExponent);
      }
      else
      {
         glUniform4fv(_uniforms[AGLKLight1Diffuse], 1, 
            GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f).v);
      }
      
      // Light2
      // Material diffuse interaction with light is baked in
      // so there is no reason to send material diffuse
      // color to shaders
      if(self.light2.enabled)
      {
         glUniform3fv(_uniforms[AGLKLight2Pos], 1, 
            self.light2EyePosition.v);
         glUniform4fv(_uniforms[AGLKLight2Diffuse], 1, 
            GLKVector4Multiply(self.light2.diffuseColor,
               self.material.diffuseColor).v);
      }
      else
      {
         glUniform4fv(_uniforms[AGLKLight2Diffuse], 1, 
            GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f).v);
      }
      
      // Bind all of the textures to their respective units
      glActiveTexture(GL_TEXTURE0);
      if(0 != self.texture2d0.name && self.texture2d0.enabled)
      {
         glBindTexture(GL_TEXTURE_2D, self.texture2d0.name);
      }
      else
      {
         glBindTexture(GL_TEXTURE_2D, 0);
      }
      
      glActiveTexture(GL_TEXTURE1);
      if(0 != self.texture2d1.name && self.texture2d1.enabled)
      {
         glBindTexture(GL_TEXTURE_2D, self.texture2d1.name);
      }
      else
      {
         glBindTexture(GL_TEXTURE_2D, 0);
      }
      
#ifdef DEBUG
      {  // Report any errors 
         GLenum error = glGetError();
         if(GL_NO_ERROR != error)
         {
            NSLog(@"GL Error: 0x%x", error);
         }
      }
#endif
   }
}


/////////////////////////////////////////////////////////////////
// Returns the light0 position
- (GLKVector4)light0Position
{
   return self.light0.position; 
}


/////////////////////////////////////////////////////////////////
// Call this method to set light0 position instead of setting
// effect.light0.position directly. This class needs to intercept 
// changes to light positions so that the positions can be 
// converted to eye coordinates.
- (void)setLight0Position:(GLKVector4)aPosition
{
   self.light0.position = aPosition;
   
   aPosition = GLKMatrix4MultiplyVector4(
      self.light0.transform.modelviewMatrix, 
      aPosition);
   light0EyePosition = GLKVector3Make(
         aPosition.x,
         aPosition.y,
         aPosition.z);
}


/////////////////////////////////////////////////////////////////
// Returns light0 spot direction
- (GLKVector3)light0SpotDirection
{
   return self.light0.spotDirection; 
}


/////////////////////////////////////////////////////////////////
// Call this method to set light0 spot direction instead of 
// setting effect.light0.spotDirection directly. This class needs
// to intercept changes to convert to eye coordinates and 
// renormalize.
- (void)setLight0SpotDirection:(GLKVector3)aDirection
{
   self.light0.spotDirection = aDirection;
   
   aDirection = GLKMatrix4MultiplyVector3(
      self.light0.transform.modelviewMatrix, 
      aDirection);
   self.light0EyeDirection = GLKVector3Normalize(
      GLKVector3Make(
         aDirection.x,
         aDirection.y,
         aDirection.z));
}


/////////////////////////////////////////////////////////////////
// Returns the light1 position
- (GLKVector4)light1Position
{
   return self.light1.position; 
}


/////////////////////////////////////////////////////////////////
// Call this method to set light1 position instead of setting
// effect.light1.position directly. This class needs to intercept 
// changes to light positions so that the positions can be 
// converted to eye coordinates.
- (void)setLight1Position:(GLKVector4)aPosition
{
   self.light1.position = aPosition;
   
   aPosition = GLKMatrix4MultiplyVector4(
      self.light1.transform.modelviewMatrix, 
      aPosition);
   light1EyePosition = GLKVector3Make(
         aPosition.x,
         aPosition.y,
         aPosition.z);
}


/////////////////////////////////////////////////////////////////
// Returns light1 spot direction
- (GLKVector3)light1SpotDirection
{
   return self.light1.spotDirection; 
}


/////////////////////////////////////////////////////////////////
// Call this method to set light1 spot direction instead of 
// setting effect.light1.spotDirection directly. This class needs
// to intercept changes to convert to eye coordinates and 
// renormalize.
- (void)setLight1SpotDirection:(GLKVector3)aDirection
{
   self.light1.spotDirection = aDirection;
   
   aDirection = GLKMatrix4MultiplyVector3(
      self.light1.transform.modelviewMatrix, 
      aDirection);
   self.light1EyeDirection = GLKVector3Normalize(
      GLKVector3Make(
         aDirection.x,
         aDirection.y,
         aDirection.z));
}


/////////////////////////////////////////////////////////////////
// Returns the light2 position
- (GLKVector4)light2Position
{
   return self.light2.position; 
}


/////////////////////////////////////////////////////////////////
// Call this method to set light2 position instead of setting
// effect.light2.position directly. This class needs to intercept 
// changes to light positions so that the positions can be 
// converted to eye coordinates.
- (void)setLight2Position:(GLKVector4)aPosition
{
   self.light2.position = aPosition;
   
   aPosition = GLKMatrix4MultiplyVector4(
      self.light2.transform.modelviewMatrix, 
      aPosition);
   light2EyePosition = GLKVector3Make(
         aPosition.x,
         aPosition.y,
         aPosition.z);
}


#pragma mark -  OpenGL ES 2 shader compilation

/////////////////////////////////////////////////////////////////
// The method loads, compiles, links, and initializes Shader
// Language programs used by the receiver. Returns YEs if
// successfull. Logs an error message and returns NO otherwise.
// This method is based on Apple's sample code.
- (BOOL)loadShaders
{
   GLuint vertShader, fragShader;
   NSString *vertShaderPathname, *fragShaderPathname;
   
   // Create shader program.
   _program = glCreateProgram();
   
   // Create and compile vertex shader.
   vertShaderPathname = [[NSBundle mainBundle] pathForResource:
      @"AGLKTextureMatrix2PointLightShader" ofType:@"vsh"];
   if (![self compileShader:&vertShader type:GL_VERTEX_SHADER 
      file:vertShaderPathname]) 
   {
      NSLog(@"Failed to compile vertex shader");
      return NO;
   }
   
   // Create and compile fragment shader.
   fragShaderPathname = [[NSBundle mainBundle] pathForResource:
      @"AGLKTextureMatrix2PointLightShader" ofType:@"fsh"];
   if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER 
      file:fragShaderPathname]) 
   {
      NSLog(@"Failed to compile fragment shader");
      return NO;
   }
   
   // Attach vertex shader to program.
   glAttachShader(_program, vertShader);
   
   // Attach fragment shader to program.
   glAttachShader(_program, fragShader);
   
   // Bind attribute locations.
   // This needs to be done prior to linking.
   glBindAttribLocation(_program, GLKVertexAttribPosition, 
      "a_position");
   glBindAttribLocation(_program, GLKVertexAttribNormal, 
      "a_normal");
   glBindAttribLocation(_program, GLKVertexAttribTexCoord0, 
      "a_texCoord0");
   glBindAttribLocation(_program, GLKVertexAttribTexCoord1, 
      "a_texCoord1");
   
   // Link program.
   if (![self linkProgram:_program]) 
   {
      NSLog(@"Failed to link program: %d", _program);
      
      if (vertShader) 
      {
         glDeleteShader(vertShader);
         vertShader = 0;
      }
      if (fragShader) 
      {
         glDeleteShader(fragShader);
         fragShader = 0;
      }
      if (_program) 
      {
         glDeleteProgram(_program);
         _program = 0;
      }
      
      return NO;
   }
   
   // Get uniform locations.
   _uniforms[AGLKModelviewMatrix] = glGetUniformLocation(_program, "u_modelviewMatrix");
   _uniforms[AGLKMVPMatrix] = glGetUniformLocation(_program, 
      "u_mvpMatrix");
   _uniforms[AGLKNormalMatrix] = glGetUniformLocation(_program, 
      "u_normalMatrix");
   _uniforms[AGLKTex0Matrix] = glGetUniformLocation(_program, 
      "u_tex0Matrix");
   _uniforms[AGLKTex1Matrix] = glGetUniformLocation(_program, 
      "u_tex1Matrix");
   _uniforms[AGLKSamplers] = glGetUniformLocation(_program, 
      "u_unit2d");
   _uniforms[AGLKTex0Enabled] = glGetUniformLocation(_program, 
      "u_tex0Enabled");
   _uniforms[AGLKTex1Enabled] = glGetUniformLocation(_program, 
      "u_tex1Enabled");
   _uniforms[AGLKGlobalAmbient] = glGetUniformLocation(_program, 
      "u_globalAmbient");
   _uniforms[AGLKLight0Pos] = glGetUniformLocation(_program, 
      "u_light0EyePos");
   _uniforms[AGLKLight0Direction] = glGetUniformLocation(_program, "u_light0NormalEyeDirection");
   _uniforms[AGLKLight0Diffuse] = glGetUniformLocation(_program, 
      "u_light0Diffuse");
   _uniforms[AGLKLight0Cutoff] = glGetUniformLocation(_program, 
      "u_light0Cutoff");
   _uniforms[AGLKLight0Exponent] = glGetUniformLocation(_program, "u_light0Exponent");
   _uniforms[AGLKLight1Pos] = glGetUniformLocation(_program, 
      "u_light1EyePos");
   _uniforms[AGLKLight1Direction] = glGetUniformLocation(_program, "u_light1NormalEyeDirection");
   _uniforms[AGLKLight1Diffuse] = glGetUniformLocation(_program, 
      "u_light1Diffuse");
   _uniforms[AGLKLight1Cutoff] = glGetUniformLocation(_program, 
      "u_light1Cutoff");
   _uniforms[AGLKLight1Exponent] = glGetUniformLocation(_program, "u_light1Exponent");
   _uniforms[AGLKLight2Pos] = glGetUniformLocation(_program, 
      "u_light2EyePos");
   _uniforms[AGLKLight2Diffuse] = glGetUniformLocation(_program, 
      "u_light2Diffuse");
   
   // Delete vertex and fragment shaders.
   if (vertShader) 
   {
      glDetachShader(_program, vertShader);
      glDeleteShader(vertShader);
   }
   if (fragShader) 
   {
      glDetachShader(_program, fragShader);
      glDeleteShader(fragShader);
   }
   
   return YES;
}


/////////////////////////////////////////////////////////////////
// Returns YES if the Shading Language program in file
// compiles successfully. Logs an error message and returns NO 
// otherwise. Returns newly created Shader ID in shader.
// This method is based on Apple's sample code.
- (BOOL)compileShader:(GLuint *)shader 
  type:(GLenum)type 
  file:(NSString *)file
{
   GLint status;
   const GLchar *source;
   
   source = (GLchar *)[[NSString stringWithContentsOfFile:file 
      encoding:NSUTF8StringEncoding error:nil] UTF8String];
   if (!source) 
   {
      NSLog(@"Failed to load vertex shader");
      return NO;
   }
   
   *shader = glCreateShader(type);
   glShaderSource(*shader, 1, &source, NULL);
   glCompileShader(*shader);
   
#if defined(DEBUG)
   GLint logLength;
   glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
   if (logLength > 0) 
   {
      GLchar *log = (GLchar *)malloc(logLength);
      glGetShaderInfoLog(*shader, logLength, &logLength, log);
      NSLog(@"Shader compile log:\n%s", log);
      free(log);
   }
#endif
   
   glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
   if (status == 0) 
   {
      glDeleteShader(*shader);
      return NO;
   }
   
   return YES;
}


/////////////////////////////////////////////////////////////////
// Returns YES if the receiver's Shading Language programs
// link successfully. Logs an error message and returns NO 
// otherwise.
// This method is based on Apple's sample code.
- (BOOL)linkProgram:(GLuint)prog
{
   GLint status;
   glLinkProgram(prog);
   
#if defined(DEBUG)
   GLint logLength;
   glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
   if (logLength > 0) {
      GLchar *log = (GLchar *)malloc(logLength);
      glGetProgramInfoLog(prog, logLength, &logLength, log);
      NSLog(@"Program link log:\n%s", log);
      free(log);
   }
#endif
   
   glGetProgramiv(prog, GL_LINK_STATUS, &status);
   if (status == 0) {
      return NO;
   }
   
   return YES;
}


/////////////////////////////////////////////////////////////////
// Returns YES if the receiver's Shading Language programs
// are valid. Logs an error message and returns NO otherwise.
// This method is based on Apple's sample code.
- (BOOL)validateProgram:(GLuint)prog
{
   GLint logLength, status;
   
   glValidateProgram(prog);
   glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
   if (logLength > 0) {
      GLchar *log = (GLchar *)malloc(logLength);
      glGetProgramInfoLog(prog, logLength, &logLength, log);
      NSLog(@"Program validate log:\n%s", log);
      free(log);
   }
   
   glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
   if (status == 0) {
      return NO;
   }
   
   return YES;
}

@end


#pragma mark -  GLKEffectPropertyTexture (AGLKAdditions)

@implementation GLKEffectPropertyTexture (AGLKAdditions)

/////////////////////////////////////////////////////////////////
// This method wraps the OpenGL glTexParameteri() function
// and provides a place to implement side effects to state
// changes.
- (void)aglkSetParameter:(GLenum)parameterID 
   value:(GLint)value;
{
   glBindTexture(self.target, self.name);

   glTexParameteri(
      self.target, 
      parameterID, 
      value);
}
   
@end
