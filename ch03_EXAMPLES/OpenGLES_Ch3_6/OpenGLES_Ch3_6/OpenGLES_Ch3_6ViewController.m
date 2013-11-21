//
//  OpenGLES_Ch3_6ViewController.m
//  OpenGLES_Ch3_6
//

#import "OpenGLES_Ch3_6ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

@interface GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID 
   value:(GLint)value;
   
@end


@implementation GLKEffectPropertyTexture (AGLKAdditions)

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


@interface OpenGLES_Ch3_6ViewController ()

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end


@implementation OpenGLES_Ch3_6ViewController

@synthesize baseEffect;
@synthesize vertexBuffer;

/////////////////////////////////////////////////////////////////
// GLSL program uniform indices.
enum
{
   UNIFORM_MODELVIEWPROJECTION_MATRIX,
   UNIFORM_NORMAL_MATRIX,
   UNIFORM_TEXTURE0_SAMPLER2D,
   UNIFORM_TEXTURE1_SAMPLER2D,
   NUM_UNIFORMS
};


/////////////////////////////////////////////////////////////////
// GLSL program uniform IDs.
GLint uniforms[NUM_UNIFORMS];


/////////////////////////////////////////////////////////////////
// This data type is used to store information for each vertex
typedef struct {
   GLKVector3  positionCoords;
   GLKVector3  normalCoords;
   GLKVector2  textureCoords;
}
SceneVertex;

/////////////////////////////////////////////////////////////////
// Define vertex data for a triangle to use in example
static const SceneVertex vertices[] = 
{
   {{ 0.5f, -0.5f, -0.5f}, { 1.0f,  0.0f,  0.0f}, {0.0f, 0.0f}},
   {{ 0.5f,  0.5f, -0.5f}, { 1.0f,  0.0f,  0.0f}, {1.0f, 0.0f}}, 
   {{ 0.5f, -0.5f,  0.5f}, { 1.0f,  0.0f,  0.0f}, {0.0f, 1.0f}},
   {{ 0.5f, -0.5f,  0.5f}, { 1.0f,  0.0f,  0.0f}, {0.0f, 1.0f}},
   {{ 0.5f,  0.5f,  0.5f}, { 1.0f,  0.0f,  0.0f}, {1.0f, 1.0f}},
   {{ 0.5f,  0.5f, -0.5f}, { 1.0f,  0.0f,  0.0f}, {1.0f, 0.0f}},
   
   {{ 0.5f,  0.5f, -0.5f}, { 0.0f,  1.0f,  0.0f}, {1.0f, 0.0f}},
   {{-0.5f,  0.5f, -0.5f}, { 0.0f,  1.0f,  0.0f}, {0.0f, 0.0f}},
   {{ 0.5f,  0.5f,  0.5f}, { 0.0f,  1.0f,  0.0f}, {1.0f, 1.0f}},
   {{ 0.5f,  0.5f,  0.5f}, { 0.0f,  1.0f,  0.0f}, {1.0f, 1.0f}},
   {{-0.5f,  0.5f, -0.5f}, { 0.0f,  1.0f,  0.0f}, {0.0f, 0.0f}},
   {{-0.5f,  0.5f,  0.5f}, { 0.0f,  1.0f,  0.0f}, {0.0f, 1.0f}},
   
   {{-0.5f,  0.5f, -0.5f}, {-1.0f,  0.0f,  0.0f}, {1.0f, 0.0f}},
   {{-0.5f, -0.5f, -0.5f}, {-1.0f,  0.0f,  0.0f}, {0.0f, 0.0f}},
   {{-0.5f,  0.5f,  0.5f}, {-1.0f,  0.0f,  0.0f}, {1.0f, 1.0f}},
   {{-0.5f,  0.5f,  0.5f}, {-1.0f,  0.0f,  0.0f}, {1.0f, 1.0f}},
   {{-0.5f, -0.5f, -0.5f}, {-1.0f,  0.0f,  0.0f}, {0.0f, 0.0f}},
   {{-0.5f, -0.5f,  0.5f}, {-1.0f,  0.0f,  0.0f}, {0.0f, 1.0f}},
   
   {{-0.5f, -0.5f, -0.5f}, { 0.0f, -1.0f,  0.0f}, {0.0f, 0.0f}},
   {{ 0.5f, -0.5f, -0.5f}, { 0.0f, -1.0f,  0.0f}, {1.0f, 0.0f}},
   {{-0.5f, -0.5f,  0.5f}, { 0.0f, -1.0f,  0.0f}, {0.0f, 1.0f}},
   {{-0.5f, -0.5f,  0.5f}, { 0.0f, -1.0f,  0.0f}, {0.0f, 1.0f}},
   {{ 0.5f, -0.5f, -0.5f}, { 0.0f, -1.0f,  0.0f}, {1.0f, 0.0f}},
   {{ 0.5f, -0.5f,  0.5f}, { 0.0f, -1.0f,  0.0f}, {1.0f, 1.0f}},
   
   {{ 0.5f,  0.5f,  0.5f}, { 0.0f,  0.0f,  1.0f}, {1.0f, 1.0f}},
   {{-0.5f,  0.5f,  0.5f}, { 0.0f,  0.0f,  1.0f}, {0.0f, 1.0f}},
   {{ 0.5f, -0.5f,  0.5f}, { 0.0f,  0.0f,  1.0f}, {1.0f, 0.0f}},
   {{ 0.5f, -0.5f,  0.5f}, { 0.0f,  0.0f,  1.0f}, {1.0f, 0.0f}},
   {{-0.5f,  0.5f,  0.5f}, { 0.0f,  0.0f,  1.0f}, {0.0f, 1.0f}},
   {{-0.5f, -0.5f,  0.5f}, { 0.0f,  0.0f,  1.0f}, {0.0f, 0.0f}},
   
   {{ 0.5f, -0.5f, -0.5f}, { 0.0f,  0.0f, -1.0f}, {4.0f, 0.0f}},
   {{-0.5f, -0.5f, -0.5f}, { 0.0f,  0.0f, -1.0f}, {0.0f, 0.0f}},
   {{ 0.5f,  0.5f, -0.5f}, { 0.0f,  0.0f, -1.0f}, {4.0f, 4.0f}},
   {{ 0.5f,  0.5f, -0.5f}, { 0.0f,  0.0f, -1.0f}, {4.0f, 4.0f}},
   {{-0.5f, -0.5f, -0.5f}, { 0.0f,  0.0f, -1.0f}, {0.0f, 0.0f}},
   {{-0.5f,  0.5f, -0.5f}, { 0.0f,  0.0f, -1.0f}, {0.0f, 4.0f}},
};


/////////////////////////////////////////////////////////////////
// Called when the view controller's view is loaded
// Perform initialization before the view is asked to draw
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   // Verify the type of view created automatically by the
   // Interface Builder storyboard
   GLKView *view = (GLKView *)self.view;
   NSAssert([view isKindOfClass:[GLKView class]],
      @"View controller's view is not a GLKView");
   
   // Create an OpenGL ES 2.0 context and provide it to the
   // view
   view.context = [[AGLKContext alloc] 
      initWithAPI:kEAGLRenderingAPIOpenGLES2];
   view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
   
   // Make the new context current
   [AGLKContext setCurrentContext:view.context];
   
   [self loadShaders];
   
   // Create a base effect that provides standard OpenGL ES 2.0
   // shading language programs and set constants to be used for 
   // all subsequent rendering
   self.baseEffect = [[GLKBaseEffect alloc] init];
   self.baseEffect.light0.enabled = GL_TRUE;
   self.baseEffect.light0.diffuseColor = GLKVector4Make(
      0.7f, // Red 
      0.7f, // Green 
      0.7f, // Blue 
      1.0f);// Alpha 
   
   glEnable(GL_DEPTH_TEST);
   
   // Set the background color stored in the current context 
   ((AGLKContext *)view.context).clearColor = GLKVector4Make(
      0.65f, // Red 
      0.65f, // Green 
      0.65f, // Blue 
      1.0f);// Alpha 
   
   // Create vertex buffer containing vertices to draw
   self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]
      initWithAttribStride:sizeof(SceneVertex)
      numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)
      bytes:vertices
      usage:GL_STATIC_DRAW];
   
   // Setup texture0
   CGImageRef imageRef0 = 
      [[UIImage imageNamed:@"leaves.gif"] CGImage];
      
   GLKTextureInfo *textureInfo0 = [GLKTextureLoader 
      textureWithCGImage:imageRef0 
      options:[NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:YES], 
         GLKTextureLoaderOriginBottomLeft, nil] 
      error:NULL];
      
   self.baseEffect.texture2d0.name = textureInfo0.name;
   self.baseEffect.texture2d0.target = textureInfo0.target;
   [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_S 
      value:GL_REPEAT];
   [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_T 
      value:GL_REPEAT];
         
   // Setup texture1
   CGImageRef imageRef1 = 
      [[UIImage imageNamed:@"beetle.png"] CGImage];
      
   GLKTextureInfo *textureInfo1 = [GLKTextureLoader 
      textureWithCGImage:imageRef1 
      options:[NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:YES], 
         GLKTextureLoaderOriginBottomLeft, nil] 
      error:NULL];

   self.baseEffect.texture2d1.name = textureInfo1.name;
   self.baseEffect.texture2d1.target = textureInfo1.target;
   self.baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
   [self.baseEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_S 
      value:GL_REPEAT];
   [self.baseEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_T 
      value:GL_REPEAT];
}


/////////////////////////////////////////////////////////////////
// 
- (void)update
{
   float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
   GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
   
   self.baseEffect.transform.projectionMatrix = projectionMatrix;
   
   GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
   baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
   
   // Compute the model view matrix for the object rendered with GLKit
   GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
   modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
   modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
   
   self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
   
   // Compute the model view matrix for the object rendered with ES2
   modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
   modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
   modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
   
   _normalMatrix = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(modelViewMatrix, NULL));
   
   _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
   
   _rotation += self.timeSinceLastUpdate * 0.5f;
}

/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{   
   // Clear back frame buffer (erase previous drawing)
   [(AGLKContext *)view.context clear:
      GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
   
   [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
      numberOfCoordinates:3
      attribOffset:offsetof(SceneVertex, positionCoords)
      shouldEnable:YES];

   [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal
      numberOfCoordinates:3
      attribOffset:offsetof(SceneVertex, normalCoords)
      shouldEnable:YES];

   [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
      numberOfCoordinates:2
      attribOffset:offsetof(SceneVertex, textureCoords)
      shouldEnable:YES];
   
   [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord1
      numberOfCoordinates:2
      attribOffset:offsetof(SceneVertex, textureCoords)
      shouldEnable:YES];

   [self.baseEffect prepareToDraw];

   // Draw triangles using baseEffect
   [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
      startVertexIndex:0
      numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)];

   // Render the object again with ES2
   glUseProgram(_program);
   
   glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
   glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
   glUniform1i(uniforms[UNIFORM_TEXTURE0_SAMPLER2D], 0);
   glUniform1i(uniforms[UNIFORM_TEXTURE1_SAMPLER2D], 1);
   
   glDrawArrays(GL_TRIANGLES, 0, 36);
}


/////////////////////////////////////////////////////////////////
// Called when the view controller's view has been unloaded
// Perform clean-up that is possible when you know the view 
// controller's view won't be asked to draw again soon.
- (void)viewDidUnload
{
   [super viewDidUnload];
   
   // Make the view's context current
   GLKView *view = (GLKView *)self.view;
   [AGLKContext setCurrentContext:view.context];
    
   // Delete buffers that aren't needed when view is unloaded
   self.vertexBuffer = nil;
   
   self.baseEffect = nil;
   
   if (_program) {
      glDeleteProgram(_program);
      _program = 0;
   }

   // Stop using the context created in -viewDidLoad
   ((GLKView *)self.view).context = nil;
   [EAGLContext setCurrentContext:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   // Return YES for supported orientations
   if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
   } else {
      return YES;
   }
}


#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
   GLuint vertShader, fragShader;
   NSString *vertShaderPathname, *fragShaderPathname;
   
   // Create shader program.
   _program = glCreateProgram();
   
   // Create and compile vertex shader.
   vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
   if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
      NSLog(@"Failed to compile vertex shader");
      return NO;
   }
   
   // Create and compile fragment shader.
   fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
   if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
      NSLog(@"Failed to compile fragment shader");
      return NO;
   }
   
   // Attach vertex shader to program.
   glAttachShader(_program, vertShader);
   
   // Attach fragment shader to program.
   glAttachShader(_program, fragShader);
   
   // Bind attribute locations.
   // This needs to be done prior to linking.
   glBindAttribLocation(_program, GLKVertexAttribPosition, "aPosition");
   glBindAttribLocation(_program, GLKVertexAttribNormal, "aNormal");
   glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "aTextureCoord0");
   glBindAttribLocation(_program, GLKVertexAttribTexCoord1, "aTextureCoord1");
   
   // Link program.
   if (![self linkProgram:_program]) {
      NSLog(@"Failed to link program: %d", _program);
      
      if (vertShader) {
         glDeleteShader(vertShader);
         vertShader = 0;
      }
      if (fragShader) {
         glDeleteShader(fragShader);
         fragShader = 0;
      }
      if (_program) {
         glDeleteProgram(_program);
         _program = 0;
      }
      
      return NO;
   }
   
   // Get uniform locations.
   uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "uModelViewProjectionMatrix");
   uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "uNormalMatrix");
   uniforms[UNIFORM_TEXTURE0_SAMPLER2D] = glGetUniformLocation(_program, "uSampler0");
   uniforms[UNIFORM_TEXTURE1_SAMPLER2D] = glGetUniformLocation(_program, "uSampler1");
   
   // Release vertex and fragment shaders.
   if (vertShader) {
      glDetachShader(_program, vertShader);
      glDeleteShader(vertShader);
   }
   if (fragShader) {
      glDetachShader(_program, fragShader);
      glDeleteShader(fragShader);
   }
   
   return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
   GLint status;
   const GLchar *source;
   
   source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
   if (!source) {
      NSLog(@"Failed to load vertex shader");
      return NO;
   }
   
   *shader = glCreateShader(type);
   glShaderSource(*shader, 1, &source, NULL);
   glCompileShader(*shader);
   
#if defined(DEBUG)
   GLint logLength;
   glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
   if (logLength > 0) {
      GLchar *log = (GLchar *)malloc(logLength);
      glGetShaderInfoLog(*shader, logLength, &logLength, log);
      NSLog(@"Shader compile log:\n%s", log);
      free(log);
   }
#endif
   
   glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
   if (status == 0) {
      glDeleteShader(*shader);
      return NO;
   }
   
   return YES;
}

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
