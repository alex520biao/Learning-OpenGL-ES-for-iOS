//
//  OpenGLES_Ch5_2ViewController.m
//  OpenGLES_Ch5_2
//

#import "OpenGLES_Ch5_2ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "sphere.h"             // Vertex data for a sphere


@implementation OpenGLES_Ch5_2ViewController

@synthesize baseEffect;
@synthesize vertexPositionBuffer;
@synthesize vertexNormalBuffer;
@synthesize vertexTextureCoordBuffer;

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
   view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
   
   // Create an OpenGL ES 2.0 context and provide it to the
   // view
   view.context = [[AGLKContext alloc] 
      initWithAPI:kEAGLRenderingAPIOpenGLES2];
   
   // Make the new context current
   [AGLKContext setCurrentContext:view.context];
   
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
   self.baseEffect.light0.position = GLKVector4Make(
      1.0f,  
      0.0f,  
     -0.8f,  
      0.0f);
   self.baseEffect.light0.ambientColor = GLKVector4Make(
      0.2f, // Red 
      0.2f, // Green 
      0.2f, // Blue 
      1.0f);// Alpha 

   // Setup texture
   CGImageRef imageRef = 
      [[UIImage imageNamed:@"Earth512x256.jpg"] CGImage];
      
   GLKTextureInfo *textureInfo = [GLKTextureLoader 
      textureWithCGImage:imageRef 
      options:[NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:YES], 
         GLKTextureLoaderOriginBottomLeft, nil] 
      error:NULL];
            
   self.baseEffect.texture2d0.name = textureInfo.name;
   self.baseEffect.texture2d0.target = textureInfo.target;
    
   // Set the background color stored in the current context 
   ((AGLKContext *)view.context).clearColor = GLKVector4Make(
      0.0f, // Red 
      0.0f, // Green 
      0.0f, // Blue 
      1.0f);// Alpha 
   
   // Create vertex buffers containing vertices to draw
   self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
      initWithAttribStride:(3 * sizeof(GLfloat))
      numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat))
      bytes:sphereVerts
      usage:GL_STATIC_DRAW]; 
   self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
      initWithAttribStride:(3 * sizeof(GLfloat))
      numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat))
      bytes:sphereNormals
      usage:GL_STATIC_DRAW];
   self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
      initWithAttribStride:(2 * sizeof(GLfloat))
      numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat))
      bytes:sphereTexCoords
      usage:GL_STATIC_DRAW]; 

   glEnable(GL_DEPTH_TEST);
}


/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{      
   [self.baseEffect prepareToDraw];
   
   // Clear back frame buffer (erase previous drawing)
   [(AGLKContext *)view.context 
      clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
   
   [self.vertexPositionBuffer 
      prepareToDrawWithAttrib:GLKVertexAttribPosition
      numberOfCoordinates:3
      attribOffset:0
      shouldEnable:YES];
   [self.vertexNormalBuffer 
      prepareToDrawWithAttrib:GLKVertexAttribNormal
      numberOfCoordinates:3
      attribOffset:0
      shouldEnable:YES];
   [self.vertexTextureCoordBuffer 
      prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
      numberOfCoordinates:2
      attribOffset:0
      shouldEnable:YES];

   // Scale the Y coordinate based on the aspect ratio of the
   // view's Layer which matches the screen aspect ratio for
   // this example 
   const GLfloat  aspectRatio = 
      (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;

   self.baseEffect.transform.projectionMatrix = 
      GLKMatrix4MakeScale(1.0f, aspectRatio, 1.0f);
   
   // Draw triangles using vertices in the prepared vertex
   // buffers
   [AGLKVertexAttribArrayBuffer 
      drawPreparedArraysWithMode:GL_TRIANGLES
      startVertexIndex:0
      numberOfVertices:sphereNumVerts];
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
   self.vertexPositionBuffer = nil;
   self.vertexNormalBuffer = nil;
   self.vertexTextureCoordBuffer = nil;
   
   // Stop using the context created in -viewDidLoad
   ((GLKView *)self.view).context = nil;
   [EAGLContext setCurrentContext:nil];
}

@end
