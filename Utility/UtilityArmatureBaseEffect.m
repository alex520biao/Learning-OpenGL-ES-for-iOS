//
//  UtilityArmatureBaseEffect.m
// 
//

#import "UtilityArmatureBaseEffect.h"
//#import "AGLKVertexAttribArrayBuffer.h"
#import "UtilityJoint.h"

/////////////////////////////////////////////////////////////////
// INDEXED MATRICES FOR ARMATURE
#define MAX_INDEXED_MATRICES  (16)


/////////////////////////////////////////////////////////////////
// GLSL program uniform indices.
enum
{
   AGLKModelviewMatrix,
   AGLKMVPMatrix,
   AGLKNormalMatrix,
   AGLKTex0Matrix,
   AGLKTex1Matrix,
   AGLKSamplers2D,
   AGLKTex0Enabled,
   AGLKTex1Enabled,
   AGLKGlobalAmbient,
   AGLKLight0EyePosition,
   AGLKLight0Diffuse,
   AGLKMVPJointMatrices,
   AGLKNormalJointNormalMatrices,
   AGLKNumUniforms
};


@interface UtilityArmatureBaseEffect ()
{
   GLuint _program;
   GLint _uniforms[AGLKNumUniforms];
}

@property (nonatomic, assign) GLKVector3 light0EyePosition;
@property (nonatomic, assign) GLKVector3 light0EyeDirection;
@property (nonatomic, assign) GLKVector3 light1EyePosition;
@property (nonatomic, assign) GLKVector3 light1EyeDirection;
@property (nonatomic, assign) GLKVector3 light2EyePosition;
@property (nonatomic, assign) GLKMatrix4 
   *mvpArmatureJointMatrices;
@property (nonatomic, assign) GLKMatrix3
   *normalArmatureJointNormalMatrices;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader 
   type:(GLenum)type 
   file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end


@implementation UtilityArmatureBaseEffect

@synthesize textureMatrix2d0;
@synthesize textureMatrix2d1;
@synthesize light0EyePosition;
@synthesize light0EyeDirection;
@synthesize light1EyePosition;
@synthesize light1EyeDirection;
@synthesize light2EyePosition;
@synthesize mvpArmatureJointMatrices;
@synthesize normalArmatureJointNormalMatrices;
@synthesize jointsArray;
@synthesize light0Position;
@synthesize light0SpotDirection;
@synthesize light1Position;
@synthesize light1SpotDirection;
@synthesize light2Position;

/////////////////////////////////////////////////////////////////
// 
- (id)init
{
   if(nil != (self = [super init]))
   {
      textureMatrix2d0 = GLKMatrix4Identity;
      textureMatrix2d1 = GLKMatrix4Identity;
      self.texture2d0.enabled = GL_FALSE;
      self.texture2d1.enabled = GL_FALSE;
      
      mvpArmatureJointMatrices = calloc(sizeof(GLKMatrix4), 
         MAX_INDEXED_MATRICES);
      normalArmatureJointNormalMatrices = calloc(sizeof(GLKMatrix3), MAX_INDEXED_MATRICES);
      
      for(int i = 0; i < MAX_INDEXED_MATRICES; i++)
      {
         mvpArmatureJointMatrices[i] = GLKMatrix4Identity;
         normalArmatureJointNormalMatrices[i] = GLKMatrix3Identity;
      }      
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// 
- (void)prepareToDrawArmature
{
   // Precalculate the mvpMatrix
   GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(
      self.transform.projectionMatrix, 
      self.transform.modelviewMatrix);
      
   self.mvpArmatureJointMatrices[0] = modelViewProjectionMatrix;
   self.normalArmatureJointNormalMatrices[0] = 
      self.transform.normalMatrix;
   NSUInteger jointMatrixIndex = 1;
   
   for(UtilityJoint *joint in self.jointsArray)
   {  // Set the corresponding mvpArmatureJointMatrix to
      // the joint matrix concatenated with the mvp matrix.
      if(jointMatrixIndex < MAX_INDEXED_MATRICES)
      {
         GLKMatrix4 tempMatrix = joint.cumulativeTransforms;
         
         self.mvpArmatureJointMatrices[jointMatrixIndex] = 
            GLKMatrix4Multiply(modelViewProjectionMatrix,
               tempMatrix);

         // Calculate normal matrix for the aramture matrix
         bool isInvertible;
         
         GLKMatrix3 jointNormalMatrix = GLKMatrix4GetMatrix3(
            GLKMatrix4InvertAndTranspose(tempMatrix, 
               &isInvertible));
               
         if(isInvertible)
         {
            jointNormalMatrix = GLKMatrix3Multiply(
               self.transform.normalMatrix, jointNormalMatrix);
         }
         else
         {
            jointNormalMatrix = self.transform.normalMatrix;
         }
         
         self.normalArmatureJointNormalMatrices[jointMatrixIndex] =
               jointNormalMatrix;
      }
      jointMatrixIndex++;
      
   }

   if(0 == _program)
   {
      [self loadShaders];
   }
   
   if(0 != _program)
   {
      glUseProgram(_program);
      
      // Local storage for texture sampler IDs
      const GLuint   samplerIDs[2] = {0, 1};
      
      // Standard matrices
      glUniformMatrix4fv(_uniforms[AGLKModelviewMatrix], 1, 
         GL_FALSE, self.transform.modelviewMatrix.m);
      glUniformMatrix4fv(_uniforms[AGLKMVPMatrix], 1, 0, 
         modelViewProjectionMatrix.m);
      glUniformMatrix3fv(_uniforms[AGLKNormalMatrix], 1, 
         GL_FALSE, self.transform.normalMatrix.m);      
      glUniformMatrix4fv(_uniforms[AGLKTex0Matrix], 1, 
         GL_FALSE, self.textureMatrix2d0.m);
      glUniformMatrix4fv(_uniforms[AGLKTex1Matrix], 1, 
         GL_FALSE, self.textureMatrix2d1.m);
         
      // Two texture samplers
      glUniform1iv(_uniforms[AGLKSamplers2D], 2, 
         (const GLint *)samplerIDs); 

      // Precalculate teh global ambient light contribution
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
         GLKVector3 normalizedEyePosition = 
            GLKVector3Normalize(light0EyePosition);
            
         glUniform3fv(_uniforms[AGLKLight0EyePosition], 1, 
            normalizedEyePosition.v);
         glUniform4fv(_uniforms[AGLKLight0Diffuse], 1, 
            GLKVector4Multiply(self.light0.diffuseColor,
               self.material.diffuseColor).v);
      }
      else
      {
         glUniform4fv(_uniforms[AGLKLight0Diffuse], 1, 
            GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f).v);
      }
      
      // Armature matrices
      glUniformMatrix4fv(_uniforms[AGLKMVPJointMatrices], 
         MAX_INDEXED_MATRICES,
         GL_FALSE, self.mvpArmatureJointMatrices[0].m);      
      glUniformMatrix3fv(_uniforms[AGLKNormalJointNormalMatrices], 
         MAX_INDEXED_MATRICES,
         GL_FALSE, self.normalArmatureJointNormalMatrices[0].m);      
      
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
// 
- (GLKVector4)light0Position
{
   return self.light0.position; 
}


/////////////////////////////////////////////////////////////////
// 
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
// 
- (GLKVector3)light0SpotDirection
{
   return self.light0.spotDirection; 
}


/////////////////////////////////////////////////////////////////
// 
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
// 
- (GLKVector4)light1Position
{
   return self.light1.position; 
}


/////////////////////////////////////////////////////////////////
// 
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
// 
- (GLKVector3)light1SpotDirection
{
   return self.light1.spotDirection; 
}


/////////////////////////////////////////////////////////////////
// 
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
// 
- (GLKVector4)light2Position
{
   return self.light2.position; 
}


/////////////////////////////////////////////////////////////////
// 
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
// 
- (BOOL)loadShaders
{
   GLuint vertShader, fragShader;
   NSString *vertShaderPathname, *fragShaderPathname;
   
   // Create shader program.
   _program = glCreateProgram();
   
   // Create and compile vertex shader.
   vertShaderPathname = [[NSBundle mainBundle] pathForResource:
      @"UtilityArmaturePointLightShader" ofType:@"vsh"];
   if (![self compileShader:&vertShader type:GL_VERTEX_SHADER 
      file:vertShaderPathname]) 
   {
      NSLog(@"Failed to compile vertex shader");
      return NO;
   }
   
   // Create and compile fragment shader.
   fragShaderPathname = [[NSBundle mainBundle] pathForResource:
      @"UtilityArmaturePointLightShader" ofType:@"fsh"];
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
   glBindAttribLocation(_program, 
      UtilityArmatureVertexAttribPosition, 
      "a_position");
   glBindAttribLocation(_program, 
      UtilityArmatureVertexAttribNormal, 
      "a_normal");
   glBindAttribLocation(_program, 
      UtilityArmatureVertexAttribTexCoord0, 
      "a_texCoord0");
   glBindAttribLocation(_program, 
      UtilityArmatureVertexAttribTexCoord1, 
      "a_texCoord1");
   glBindAttribLocation(_program, 
      UtilityArmatureVertexAttribJointMatrixIndices, 
      "a_jointMatrixIndices");
   glBindAttribLocation(_program, 
      UtilityArmatureVertexAttribJointNormalizedWeights, 
      "a_jointNormalizedWeights");
   
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
   _uniforms[AGLKSamplers2D] = glGetUniformLocation(_program, 
      "u_samplers2D");
   _uniforms[AGLKTex0Enabled] = glGetUniformLocation(_program, 
      "u_tex0Enabled");
   _uniforms[AGLKTex1Enabled] = glGetUniformLocation(_program, 
      "u_tex1Enabled");
   _uniforms[AGLKGlobalAmbient] = glGetUniformLocation(_program, 
      "u_globalAmbient");
   _uniforms[AGLKLight0EyePosition] = glGetUniformLocation(_program, "u_light0Position");
   _uniforms[AGLKLight0Diffuse] = glGetUniformLocation(_program, 
      "u_light0Diffuse");
   _uniforms[AGLKMVPJointMatrices] = glGetUniformLocation(_program, 
      "u_mvpJointMatrices");
   _uniforms[AGLKNormalJointNormalMatrices] = 
      glGetUniformLocation(_program, "u_normalJointNormalMatrices");
   
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
// 
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
// 
- (BOOL)linkProgram:(GLuint)prog
{
   GLint status;
   glLinkProgram(prog);
   
#if defined(DEBUG)
   GLint logLength;
   glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
   if (logLength > 0) 
   {
      GLchar *log = (GLchar *)malloc(logLength);
      glGetProgramInfoLog(prog, logLength, &logLength, log);
      NSLog(@"Program link log:\n%s", log);
      free(log);
   }
#endif
   
   glGetProgramiv(prog, GL_LINK_STATUS, &status);
   if (status == 0) 
   {
      return NO;
   }
   
   return YES;
}


/////////////////////////////////////////////////////////////////
// 
- (BOOL)validateProgram:(GLuint)prog
{
   GLint logLength, status;
   
   glValidateProgram(prog);
   glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
   if (logLength > 0) 
   {
      GLchar *log = (GLchar *)malloc(logLength);
      glGetProgramInfoLog(prog, logLength, &logLength, log);
      NSLog(@"Program validate log:\n%s", log);
      free(log);
   }
   
   glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
   if (status == 0) 
   {
      return NO;
   }
   
   return YES;
}

@end


#pragma mark -  GLKEffectPropertyTexture (AGLKAdditions)

@implementation GLKEffectPropertyTexture (AGLKAdditions)

/////////////////////////////////////////////////////////////////
// 
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
