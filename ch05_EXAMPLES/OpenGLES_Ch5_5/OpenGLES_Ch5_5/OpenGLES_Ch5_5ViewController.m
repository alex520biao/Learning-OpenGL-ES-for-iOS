//
//  OpenGLES_Ch5_5ViewController.m
//  OpenGLES_Ch5_5
//

#import "OpenGLES_Ch5_5ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "AGLKTextureTransformBaseEffect.h"

@implementation OpenGLES_Ch5_5ViewController

@synthesize baseEffect;
@synthesize vertexBuffer;
@synthesize textureScaleFactor;
@synthesize textureAngle;
@synthesize textureMatrixStack;

/////////////////////////////////////////////////////////////////
// This data type is used to store information for each vertex
typedef struct {
   GLKVector3  positionCoords;
   GLKVector2  textureCoords;
}
SceneVertex;


/////////////////////////////////////////////////////////////////
// Define vertex data for triangles to use in example
static const SceneVertex vertices[] = 
{
   {{-1.0f, -0.67f, 0.0f}, {0.0f, 0.0f}},  // first triangle
   {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},
   {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
   {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},  // second triangle
   {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
   {{ 1.0f,  0.67f, 0.0f}, {1.0f, 1.0f}},
};


/////////////////////////////////////////////////////////////////
// Called when the view controller's view is loaded
// Perform initialization before the view is asked to draw
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   self.textureMatrixStack = 
      GLKMatrixStackCreate(kCFAllocatorDefault);

   self.textureScaleFactor = 1.0; // Initial texture scale factor
   
   // Verify the type of view created automatically by the
   // Interface Builder storyboard
   GLKView *view = (GLKView *)self.view;
   NSAssert([view isKindOfClass:[GLKView class]],
      @"View controller's view is not a GLKView");
   
   // Create an OpenGL ES 2.0 context and provide it to the
   // view
   view.context = [[AGLKContext alloc] 
      initWithAPI:kEAGLRenderingAPIOpenGLES2];
   
   // Make the new context current
   [AGLKContext setCurrentContext:view.context];
   
   // Create a base effect that provides standard OpenGL ES 2.0
   // shading language programs and set constants to be used for 
   // all subsequent rendering
   self.baseEffect = 
      [[AGLKTextureTransformBaseEffect alloc] init];
   //self.baseEffect = 
   //   [[GLKBaseEffect alloc] init];

   // Configure baseEffect
   self.baseEffect.useConstantColor = GL_TRUE;
   self.baseEffect.constantColor = GLKVector4Make(
      1.0f, // Red
      1.0f, // Green
      1.0f, // Blue
      1.0f);// Alpha
   
   // Set the background color stored in the current context 
   ((AGLKContext *)view.context).clearColor = GLKVector4Make(
      0.0f, // Red 
      0.0f, // Green 
      0.0f, // Blue 
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
   self.baseEffect.texture2d0.enabled = GL_TRUE;
      
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
   self.baseEffect.texture2d1.enabled = GL_TRUE;
   self.baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
   [self.baseEffect.texture2d1 
      aglkSetParameter:GL_TEXTURE_WRAP_S 
      value:GL_REPEAT];
   [self.baseEffect.texture2d1 
      aglkSetParameter:GL_TEXTURE_WRAP_T 
      value:GL_REPEAT];
   
   GLKMatrixStackLoadMatrix4(
      self.textureMatrixStack,
      self.baseEffect.textureMatrix2d1);
}


/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{   
   // Clear back frame buffer (erase previous drawing)
   [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
   
   [self.vertexBuffer 
      prepareToDrawWithAttrib:GLKVertexAttribPosition
      numberOfCoordinates:3
      attribOffset:offsetof(SceneVertex, positionCoords)
      shouldEnable:YES];

   [self.vertexBuffer 
      prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
      numberOfCoordinates:2
      attribOffset:offsetof(SceneVertex, textureCoords)
      shouldEnable:YES];
   
   [self.vertexBuffer 
      prepareToDrawWithAttrib:GLKVertexAttribTexCoord1
      numberOfCoordinates:2
      attribOffset:offsetof(SceneVertex, textureCoords)
      shouldEnable:YES];

   GLKMatrixStackPush(self.textureMatrixStack);
   
      // Scale and rotate about the center of the texture
      GLKMatrixStackTranslate(
         self.textureMatrixStack,
         0.5, 0.5, 0.0);
      GLKMatrixStackScale(
         self.textureMatrixStack,
         textureScaleFactor, textureScaleFactor, 1.0);
      GLKMatrixStackRotate(   // Rotate about Z axis
         self.textureMatrixStack,
         GLKMathDegreesToRadians(textureAngle), 
         0.0, 0.0, 1.0);
      GLKMatrixStackTranslate(
         self.textureMatrixStack,
         -0.5, -0.5, 0.0);
      
      self.baseEffect.textureMatrix2d1 = 
         GLKMatrixStackGetMatrix4(self.textureMatrixStack);
        
      [self.baseEffect prepareToDrawMultitextures];
      //[self.baseEffect prepareToDraw];

      // Draw triangles using currently bound vertex buffer
      [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
         startVertexIndex:0
         numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)];
         
   GLKMatrixStackPop(self.textureMatrixStack);
   
   self.baseEffect.textureMatrix2d1 = 
      GLKMatrixStackGetMatrix4(self.textureMatrixStack);
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
   
   // Stop using the context created in -viewDidLoad
   ((GLKView *)self.view).context = nil;
   [EAGLContext setCurrentContext:nil];
   
   CFRelease(self.textureMatrixStack);
   self.textureMatrixStack = NULL;
}


/////////////////////////////////////////////////////////////////
// This method is called by a user interface object configured
// in Interface Builder and updates the value of a global 
// variable that a texture coordinate system scale factor.
- (IBAction)takeTextureScaleFactorFrom:(UISlider *)aControl
{
   self.textureScaleFactor = [aControl value];
}


/////////////////////////////////////////////////////////////////
// This method is called by a user interface object configured
// in Interface Builder and updates the value of a global 
// variable that a texture coordinate system rotation angle.
- (IBAction)takeTextureAngleFrom:(UISlider *)aControl
{
   self.textureAngle = [aControl value];
}

@end
