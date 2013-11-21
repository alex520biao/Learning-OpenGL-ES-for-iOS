//
//  TEEffect.m
//  
//

#import "TEEffect.h"
#import <OpenGL/gl.h>


@interface TEEffect ()
{
   GLuint program;
}

- (BOOL)compileShader:(GLuint *)shader 
   type:(GLenum)type 
   file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end


@implementation TEEffect

@synthesize program;

/////////////////////////////////////////////////////////////////
//  
- (void)dealloc
{
   if(0 != program)
   {
      glUseProgram(0);
      glDeleteProgram(program);
   }
   
   [super dealloc];
}


#pragma mark -  Rendering

/////////////////////////////////////////////////////////////////
//
- (void)prepareOpenGL
{
}


/////////////////////////////////////////////////////////////////
//
- (void)updateUniformValues
{
}


/////////////////////////////////////////////////////////////////
//  
- (void)prepareToDraw;
{
   if(0 == program)
   {
      [self prepareOpenGL];
      
      NSAssert(0 != program,
         @"prepareOpenGL failed to load shaders");
   }
   
   glUseProgram(self.program);
   
   [self updateUniformValues];
}

#pragma mark -  OpenGL ES 2 shader compilation overloads

/////////////////////////////////////////////////////////////////
// 
- (void)bindAttribLocations;
{
   NSAssert(0, @"This methed mustbe overloaded in subclasses");
}


/////////////////////////////////////////////////////////////////
// 
- (void)configureUniformLocations;
{
   NSAssert(0, @"This methed mustbe overloaded in subclasses");
}


#pragma mark -  OpenGL ES 2 shader compilation

/////////////////////////////////////////////////////////////////
// 
- (BOOL)loadShadersWithName:(NSString *)aShaderName;
{
   NSParameterAssert(nil != aShaderName);
   
   GLuint vertShader, fragShader;
   NSString *vertShaderPathname, *fragShaderPathname;
   
   // Create shader program.
   program = glCreateProgram();
   
   // Create and compile vertex shader.
   vertShaderPathname = [[NSBundle mainBundle] 
      pathForResource:aShaderName ofType:@"vsh"];
   if (![self compileShader:&vertShader type:GL_VERTEX_SHADER 
      file:vertShaderPathname]) 
   {
      NSLog(@"Failed to compile vertex shader");
      return NO;
   }
   
   // Create and compile fragment shader.
   fragShaderPathname = [[NSBundle mainBundle] 
      pathForResource:aShaderName ofType:@"fsh"];
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
   [self bindAttribLocations];
   
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
   [self configureUniformLocations];
   
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
