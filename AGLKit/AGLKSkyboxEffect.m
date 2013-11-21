//
//  AGLKSkyboxEffect.m
//  
//

#import "AGLKSkyboxEffect.h"

/////////////////////////////////////////////////////////////////
// Cube has 2 triangles x 6 sides + 2 for strip = 14
const static int AGLKSkyboxNumVertexIndices = 14;

/////////////////////////////////////////////////////////////////
// Cube has 8 corners x 3 floats per vertex = 24
const static int AGLKSkyboxNumCoords = 24;

/////////////////////////////////////////////////////////////////
// GLSL program uniform indices.
enum
{
   AGLKMVPMatrix,
   AGLKSamplersCube,
   AGLKNumUniforms
};


@interface AGLKSkyboxEffect ()
{
   GLuint vertexBufferID;
   GLuint indexBufferID;
   GLuint program;
   GLuint vertexArrayID;
   GLint uniforms[AGLKNumUniforms];
}

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader 
   type:(GLenum)type 
   file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end


@implementation AGLKSkyboxEffect

@synthesize center;                
@synthesize xSize;
@synthesize ySize;
@synthesize zSize;
@synthesize textureCubeMap;
@synthesize transform;

/////////////////////////////////////////////////////////////////
// Designated initializer 
- (id)init 
{
   if (nil != (self = [super init])) 
   {
      textureCubeMap = [[GLKEffectPropertyTexture alloc] init];
      textureCubeMap.enabled = YES;
      textureCubeMap.name = 0;
      textureCubeMap.target = GLKTextureTargetCubeMap;
      textureCubeMap.envMode = GLKTextureEnvModeReplace;
      transform = [[GLKEffectPropertyTransform alloc] init];
      self.center = GLKVector3Make(0, 0, 0);
      self.xSize = 1.0f;
      self.ySize = 1.0f;
      self.zSize = 1.0f;
     
      // The 8 corners of a cube
      const float vertices[AGLKSkyboxNumCoords] = {  
          -0.5, -0.5,  0.5,
           0.5, -0.5,  0.5,
          -0.5,  0.5,  0.5,
           0.5,  0.5,  0.5,
          -0.5, -0.5, -0.5,
           0.5, -0.5, -0.5,
          -0.5,  0.5, -0.5,
           0.5,  0.5, -0.5,
      };

      glGenBuffers(1, &vertexBufferID);
      glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
      glBufferData(GL_ARRAY_BUFFER, 
         sizeof(vertices), 
         vertices, 
         GL_STATIC_DRAW);

      // Indices of triangle strip to draw cube
      // Order is critical to make "front" faces be on inside
      // of cube. 
      const GLubyte indices[AGLKSkyboxNumVertexIndices] = {
         1, 2, 3, 7, 1, 5, 4, 7, 6, 2, 4, 0, 1, 2
      };
      glGenBuffers(1, &indexBufferID);
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, 
         sizeof(indices), 
         indices, 
         GL_STATIC_DRAW);
   }

   return self;
}


/////////////////////////////////////////////////////////////////
//  
- (void)dealloc
{
   if(0 != vertexArrayID)
   {
      glDeleteVertexArraysOES(1, &vertexArrayID);
      vertexArrayID = 0;
   }   
   if(0 != indexBufferID)
   {
      glBindBuffer(GL_ARRAY_BUFFER, 0);
      glDeleteBuffers(1, &vertexBufferID);
   }
   if(0 != indexBufferID)
   {
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
      glDeleteBuffers(1, &indexBufferID);
   }
   if(0 != program)
   {
      glUseProgram(0);
      glDeleteProgram(program);
   }
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
      glUseProgram(program);                    // Step 1
   
      // Translate skybox cube to specified center and scale to 
      // specified size
      GLKMatrix4 skyboxModelView = GLKMatrix4Translate(
         self.transform.modelviewMatrix,
         self.center.x, self.center.y, self.center.z);
      skyboxModelView = GLKMatrix4Scale(
         skyboxModelView,
         self.xSize, self.ySize, self.zSize);
           
      // Pre-calculate the combined mvpMatrix
      GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(
         self.transform.projectionMatrix, 
         skyboxModelView);
         
      // Set the mvp matrix uniform variable
      glUniformMatrix4fv(uniforms[AGLKMVPMatrix], 1, 0, 
         modelViewProjectionMatrix.m);           // Step 2

      // One texture sampler uniform variable
      glUniform1i(uniforms[AGLKSamplersCube], 0);// Step 2

      if(0 == vertexArrayID)
      {  // Set vertex attribute pointers
         glGenVertexArraysOES(1, &vertexArrayID);
         glBindVertexArrayOES(vertexArrayID);      

         glEnableVertexAttribArray(GLKVertexAttribPosition);
         glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
         glVertexAttribPointer(GLKVertexAttribPosition, 
            3, 
            GL_FLOAT, 
            GL_FALSE, 
            0, 
            NULL);                               // Step 3
      }
      else
      {  // The following function call restores all of the
         // vertex attribute pointers previously prepared and 
         // associated with vertexArrayID
         glBindVertexArrayOES(vertexArrayID);      
      }
      
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);

      // Bind the texture to be used
      if(self.textureCubeMap.enabled)
      {
         glBindTexture(GL_TEXTURE_CUBE_MAP, 
            self.textureCubeMap.name);           // Step 4
      }
      else
      {
         glBindTexture(GL_TEXTURE_CUBE_MAP, 0);  // Step 4
      }
   }
}


/////////////////////////////////////////////////////////////////
// 
- (void)draw
{
   glDrawElements(GL_TRIANGLE_STRIP, 
      AGLKSkyboxNumVertexIndices, 
      GL_UNSIGNED_BYTE, 
      NULL);                                    // Step 5
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
      @"AGLKSkyboxShader" ofType:@"vsh"];
   if (![self compileShader:&vertShader type:GL_VERTEX_SHADER 
      file:vertShaderPathname]) 
   {
      NSLog(@"Failed to compile vertex shader");
      return NO;
   }
   
   // Create and compile fragment shader.
   fragShaderPathname = [[NSBundle mainBundle] pathForResource:
      @"AGLKSkyboxShader" ofType:@"fsh"];
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
   glBindAttribLocation(program, GLKVertexAttribPosition, 
      "a_position");
   
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
   uniforms[AGLKSamplersCube] = glGetUniformLocation(program, 
      "u_samplersCube");
   
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
