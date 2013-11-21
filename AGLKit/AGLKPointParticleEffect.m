//
//  AGLKPointParticleEffect.m
//  OpenGLES_Ch8_3
//

#import "AGLKPointParticleEffect.h"
#import "AGLKVertexAttribArrayBuffer.h"

/////////////////////////////////////////////////////////////////
// Type used to define particle attributes
typedef struct
{
   GLKVector3 emissionPosition;
   GLKVector3 emissionVelocity;
   GLKVector3 emissionForce;
   GLKVector2 size;
   GLKVector2 emissionTimeAndLife;
}
AGLKParticleAttributes;


/////////////////////////////////////////////////////////////////
// GLSL program uniform indices.
enum
{
   AGLKMVPMatrix,
   AGLKSamplers2D,
   AGLKElapsedSeconds,
   AGLKGravity,
   AGLKNumUniforms
};


/////////////////////////////////////////////////////////////////
// Attribute identifiers
typedef enum {
    AGLKParticleEmissionPosition = 0,
    AGLKParticleEmissionVelocity,
    AGLKParticleEmissionForce,
    AGLKParticleSize,
    AGLKParticleEmissionTimeAndLife,
} AGLKParticleAttrib;


/////////////////////////////////////////////////////////////////
// 
@interface AGLKPointParticleEffect ()
{
   GLfloat elapsedSeconds;
   GLuint program;
   GLint uniforms[AGLKNumUniforms];
}

@property (strong, nonatomic, readwrite) 
   AGLKVertexAttribArrayBuffer *particleAttributeBuffer;
@property (nonatomic, assign, readonly) NSUInteger 
   numberOfParticles;
@property (nonatomic, strong, readonly) NSMutableData  
   *particleAttributesData;
@property (nonatomic, assign, readwrite) BOOL  
   particleDataWasUpdated;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader 
   type:(GLenum)type 
   file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end


/////////////////////////////////////////////////////////////////
// 
@implementation AGLKPointParticleEffect

@synthesize gravity;                
@synthesize elapsedSeconds;
@synthesize texture2d0;
@synthesize transform;
@synthesize particleAttributeBuffer;
@synthesize particleAttributesData;
@synthesize particleDataWasUpdated;


/////////////////////////////////////////////////////////////////
// Designated initializer 
- (id)init 
{
   if (nil != (self = [super init])) 
   {
      texture2d0 = [[GLKEffectPropertyTexture alloc] init];
      texture2d0.enabled = YES;
      texture2d0.name = 0;
      texture2d0.target = GLKTextureTarget2D;
      texture2d0.envMode = GLKTextureEnvModeReplace;
      transform = [[GLKEffectPropertyTransform alloc] init];
      gravity = AGLKDefaultGravity;
      elapsedSeconds = 0.0f;
      particleAttributesData = [NSMutableData data];
   }

   return self;
}


/////////////////////////////////////////////////////////////////
//  
- (AGLKParticleAttributes)particleAtIndex:(NSUInteger)anIndex
{
   NSParameterAssert(anIndex < self.numberOfParticles);
   
   const AGLKParticleAttributes *particlesPtr = 
      (const AGLKParticleAttributes *)[self.particleAttributesData 
         bytes];
      
   return particlesPtr[anIndex]; 
}


/////////////////////////////////////////////////////////////////
//  
- (void)setParticle:(AGLKParticleAttributes)aParticle
   atIndex:(NSUInteger)anIndex
{
   NSParameterAssert(anIndex < self.numberOfParticles);
   
   AGLKParticleAttributes *particlesPtr = 
      (AGLKParticleAttributes *)[self.particleAttributesData 
         mutableBytes];
   particlesPtr[anIndex] = aParticle;

   self.particleDataWasUpdated = YES;
}


/////////////////////////////////////////////////////////////////
//  
- (void)addParticleAtPosition:(GLKVector3)aPosition
   velocity:(GLKVector3)aVelocity
   force:(GLKVector3)aForce
   size:(float)aSize
   lifeSpanSeconds:(NSTimeInterval)aSpan
   fadeDurationSeconds:(NSTimeInterval)aDuration;
{
   AGLKParticleAttributes newParticle;
   newParticle.emissionPosition = aPosition;
   newParticle.emissionVelocity = aVelocity;
   newParticle.emissionForce = aForce;
   newParticle.size = GLKVector2Make(aSize, aDuration);
   newParticle.emissionTimeAndLife = GLKVector2Make(
      self.elapsedSeconds, self.elapsedSeconds + aSpan);
   BOOL foundSlot = NO;
   const int count = self.numberOfParticles;
      
   for(int i = 0; i < count && !foundSlot; i++)
   {
      AGLKParticleAttributes oldParticle =
         [self particleAtIndex:i];
         
      if(oldParticle.emissionTimeAndLife.y < self.elapsedSeconds)
      {
         [self setParticle:newParticle atIndex:i];
         foundSlot = YES; 
      }
   }

   if(!foundSlot)
   {
      [self.particleAttributesData appendBytes:&newParticle 
         length:sizeof(newParticle)];
      self.particleDataWasUpdated = YES;
   }      
}


/////////////////////////////////////////////////////////////////
//  
- (NSUInteger)numberOfParticles;
{
   return [self.particleAttributesData length] / 
      sizeof(AGLKParticleAttributes);
}


/////////////////////////////////////////////////////////////////
//  
- (void)prepareToDraw
{
   if(0 == program)
   {
      [self loadShaders];
   }
   
   if(0 != program)
   {
      glUseProgram(program);
              
      // Precalculate the mvpMatrix
      GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(
         self.transform.projectionMatrix, 
         self.transform.modelviewMatrix);
      glUniformMatrix4fv(uniforms[AGLKMVPMatrix], 1, 0, 
         modelViewProjectionMatrix.m);

      // One texture sampler
      glUniform1i(uniforms[AGLKSamplers2D], 0); 

      // Particle physics 
      glUniform3fv(uniforms[AGLKGravity], 1, self.gravity.v);
      glUniform1fv(uniforms[AGLKElapsedSeconds], 1, &elapsedSeconds);

      if(self.particleDataWasUpdated)
      {
         if(nil == self.particleAttributeBuffer && 
            0 < [self.particleAttributesData length])
         {  // vertex attiributes haven't been sent to GPU yet
            self.particleAttributeBuffer = 
               [[AGLKVertexAttribArrayBuffer alloc]
               initWithAttribStride:sizeof(AGLKParticleAttributes)
               numberOfVertices:
                  [self.particleAttributesData length] / 
                  sizeof(AGLKParticleAttributes) 
               bytes:[self.particleAttributesData bytes]
               usage:GL_DYNAMIC_DRAW];
         }
         else
         {
            [self.particleAttributeBuffer
               reinitWithAttribStride:
                  sizeof(AGLKParticleAttributes)
               numberOfVertices:
                  [self.particleAttributesData length] / 
                  sizeof(AGLKParticleAttributes)
               bytes:[self.particleAttributesData bytes]];
         }
         
         self.particleDataWasUpdated = NO;
      }
      
      [self.particleAttributeBuffer
         prepareToDrawWithAttrib:AGLKParticleEmissionPosition
         numberOfCoordinates:3
         attribOffset:
            offsetof(AGLKParticleAttributes, emissionPosition)
         shouldEnable:YES];

      [self.particleAttributeBuffer
         prepareToDrawWithAttrib:AGLKParticleEmissionVelocity
         numberOfCoordinates:3
         attribOffset:
            offsetof(AGLKParticleAttributes, emissionVelocity)
         shouldEnable:YES];

      [self.particleAttributeBuffer
         prepareToDrawWithAttrib:AGLKParticleEmissionForce
         numberOfCoordinates:3
         attribOffset:
            offsetof(AGLKParticleAttributes, emissionForce)
         shouldEnable:YES];

      [self.particleAttributeBuffer
         prepareToDrawWithAttrib:AGLKParticleSize
         numberOfCoordinates:2
         attribOffset:
            offsetof(AGLKParticleAttributes, size)
         shouldEnable:YES];

      [self.particleAttributeBuffer
         prepareToDrawWithAttrib:AGLKParticleEmissionTimeAndLife
         numberOfCoordinates:2
         attribOffset:
            offsetof(AGLKParticleAttributes, emissionTimeAndLife)
         shouldEnable:YES];

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
   }
}


/////////////////////////////////////////////////////////////////
//  
- (void)draw;
{
   glDepthMask(GL_FALSE);  // Disable depth buffer writes
   [self.particleAttributeBuffer 
      drawArrayWithMode:GL_POINTS
      startVertexIndex:0
      numberOfVertices:self.numberOfParticles];
   glDepthMask(GL_TRUE);  // Reenable depth buffer writes
}


#pragma mark -  OpenGL ES 2 shader compilation

/////////////////////////////////////////////////////////////////
// 
- (BOOL)loadShaders
{
   GLuint vertShader, fragShader;
   NSString *vertShaderPathname, *fragShaderPathname;
   
   // Create shader program.
   program = glCreateProgram();
   
   // Create and compile vertex shader.
   vertShaderPathname = [[NSBundle mainBundle] pathForResource:
      @"AGLKPointParticleShader" ofType:@"vsh"];
   if (![self compileShader:&vertShader type:GL_VERTEX_SHADER 
      file:vertShaderPathname]) 
   {
      NSLog(@"Failed to compile vertex shader");
      return NO;
   }
   
   // Create and compile fragment shader.
   fragShaderPathname = [[NSBundle mainBundle] pathForResource:
      @"AGLKPointParticleShader" ofType:@"fsh"];
   if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER 
      file:fragShaderPathname]) 
   {
      NSLog(@"Failed to compile fragment shader");
      return NO;
   }
   
   // Attach vertex shader to program.
   glAttachShader(program, vertShader);
   
   // Attach fragment shader to program.
   glAttachShader(program, fragShader);
   
   // Bind attribute locations.
   // This needs to be done prior to linking.
   glBindAttribLocation(program, AGLKParticleEmissionPosition, 
      "a_emissionPosition");
   glBindAttribLocation(program, AGLKParticleEmissionVelocity, 
      "a_emissionVelocity");
   glBindAttribLocation(program, AGLKParticleEmissionForce, 
      "a_emissionForce");
   glBindAttribLocation(program, AGLKParticleSize, 
      "a_size");
   glBindAttribLocation(program, AGLKParticleEmissionTimeAndLife, 
      "a_emissionAndDeathTimes");
   
   // Link program.
   if (![self linkProgram:program]) 
   {
      NSLog(@"Failed to link program: %d", program);
      
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
      if (program) 
      {
         glDeleteProgram(program);
         program = 0;
      }
      
      return NO;
   }

   // Get uniform locations.
   uniforms[AGLKMVPMatrix] = glGetUniformLocation(program, 
      "u_mvpMatrix");
   uniforms[AGLKSamplers2D] = glGetUniformLocation(program, 
      "u_samplers2D");
   uniforms[AGLKGravity] = glGetUniformLocation(program, 
      "u_gravity");
   uniforms[AGLKElapsedSeconds] = glGetUniformLocation(program, 
      "u_elapsedSeconds");
   
   // Delete vertex and fragment shaders.
   if (vertShader) 
   {
      glDetachShader(program, vertShader);
      glDeleteShader(vertShader);
   }
   if (fragShader) 
   {
      glDetachShader(program, fragShader);
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


/////////////////////////////////////////////////////////////////
// Default gravity acceleration vector matches Earth's 
// {0, (-9.80665 m/s/s), 0} assuming +Y up coordinate system
const GLKVector3 AGLKDefaultGravity = {0.0f, -9.80665f, 0.0f};
