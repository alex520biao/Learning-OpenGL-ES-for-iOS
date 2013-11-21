//
//  OpenGLES_Ch5_6ViewController.m
//  OpenGLES_Ch5_6
//

#import "OpenGLES_Ch5_6ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "sphere.h"             // Vertex data for a sphere

@implementation OpenGLES_Ch5_6ViewController

@synthesize baseEffect;
@synthesize vertexPositionBuffer;
@synthesize vertexNormalBuffer;
@synthesize vertexTextureCoordBuffer;
@synthesize earthTextureInfo;
@synthesize moonTextureInfo;
@synthesize modelviewMatrixStack;
@synthesize earthRotationAngleDegrees;
@synthesize moonRotationAngleDegrees;


/////////////////////////////////////////////////////////////////
// Constants
static const GLfloat  SceneEarthAxialTiltDeg = 23.5f; 
static const GLfloat  SceneDaysPerMoonOrbit = 28.0f;
static const GLfloat  SceneMoonRadiusFractionOfEarth = 0.25;
static const GLfloat  SceneMoonDistanceFromEarth = 3.0; 
                    // Note: Moon's 
                    // distance is really 30 times the earth's 
                    // radius, but a close moon demos better

/////////////////////////////////////////////////////////////////
// Setup a light to simulate the Sun
- (void)configureLight
{
   self.baseEffect.light0.enabled = GL_TRUE;
   self.baseEffect.light0.diffuseColor = GLKVector4Make(
      1.0f, // Red 
      1.0f, // Green 
      1.0f, // Blue 
      1.0f);// Alpha 
   self.baseEffect.light0.position = GLKVector4Make(
      1.0f,  
      0.0f,  
      0.8f,  
      0.0f);
   self.baseEffect.light0.ambientColor = GLKVector4Make(
      0.2f, // Red 
      0.2f, // Green 
      0.2f, // Blue 
      1.0f);// Alpha 
}


/////////////////////////////////////////////////////////////////
// Called when the view controller's view is loaded
// Perform initialization before the view is asked to draw
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   self.modelviewMatrixStack = 
      GLKMatrixStackCreate(kCFAllocatorDefault);

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
   
   // Setup a light to simulate the Sun
   [self configureLight];
   
   // Set a reasonable initial projection
   self.baseEffect.transform.projectionMatrix = 
      GLKMatrix4MakeOrtho(
      -1.0 * 4.0 / 3.0, 
      1.0 * 4.0 / 3.0, 
      -1.0, 
      1.0, 
      1.0,
      120.0);  
      
   // Position scene with Earth near center of viewing volume
   self.baseEffect.transform.modelviewMatrix = 
      GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0);

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
   
   // Setup Earth texture
   CGImageRef earthImageRef = 
      [[UIImage imageNamed:@"Earth512x256.jpg"] CGImage];
      
   earthTextureInfo = [GLKTextureLoader 
      textureWithCGImage:earthImageRef 
      options:[NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:YES], 
         GLKTextureLoaderOriginBottomLeft, nil] 
      error:NULL];
      
   // Setup Moon texture
   CGImageRef moonImageRef = 
      [[UIImage imageNamed:@"Moon256x128.png"] CGImage];
      
   moonTextureInfo = [GLKTextureLoader 
      textureWithCGImage:moonImageRef 
      options:[NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:YES], 
         GLKTextureLoaderOriginBottomLeft, nil] 
      error:NULL];
   
   // Initialize the matrix stack
   GLKMatrixStackLoadMatrix4(
      self.modelviewMatrixStack,
      self.baseEffect.transform.modelviewMatrix);
      
   // Initialize Moon position in orbit
   self.moonRotationAngleDegrees = -20.0f;
}


/////////////////////////////////////////////////////////////////
// Draw the Earth
- (void)drawEarth
{  
   self.baseEffect.texture2d0.name = earthTextureInfo.name;
   self.baseEffect.texture2d0.target = earthTextureInfo.target;
      
   GLKMatrixStackPush(self.modelviewMatrixStack);
   
      GLKMatrixStackRotate(   // Rotate (tilt Earth's axis)
         self.modelviewMatrixStack,
         GLKMathDegreesToRadians(SceneEarthAxialTiltDeg), 
         1.0, 0.0, 0.0);
      GLKMatrixStackRotate(   // Rotate about Earth's axis
         self.modelviewMatrixStack,
         GLKMathDegreesToRadians(earthRotationAngleDegrees), 
         0.0, 1.0, 0.0);
      
      self.baseEffect.transform.modelviewMatrix = 
         GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
        
      [self.baseEffect prepareToDraw];

      // Draw triangles using vertices in the prepared vertex
      // buffers
      [AGLKVertexAttribArrayBuffer 
         drawPreparedArraysWithMode:GL_TRIANGLES
         startVertexIndex:0
         numberOfVertices:sphereNumVerts];
         
   GLKMatrixStackPop(self.modelviewMatrixStack);
   
   self.baseEffect.transform.modelviewMatrix = 
         GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
}


/////////////////////////////////////////////////////////////////
// Draw the Moon
- (void)drawMoon
{  
   self.baseEffect.texture2d0.name = moonTextureInfo.name;
   self.baseEffect.texture2d0.target = moonTextureInfo.target;
      
   GLKMatrixStackPush(self.modelviewMatrixStack);
   
      GLKMatrixStackRotate(   // Rotate to position in orbit
         self.modelviewMatrixStack,
         GLKMathDegreesToRadians(moonRotationAngleDegrees), 
         0.0, 1.0, 0.0);
      GLKMatrixStackTranslate(// Translate to distance from Earth   
         self.modelviewMatrixStack,
         0.0, 0.0, SceneMoonDistanceFromEarth);
      GLKMatrixStackScale(    // Scale to size of Moon
         self.modelviewMatrixStack,
         SceneMoonRadiusFractionOfEarth, 
         SceneMoonRadiusFractionOfEarth, 
         SceneMoonRadiusFractionOfEarth);
      GLKMatrixStackRotate(   // Rotate Moon on its own axis
         self.modelviewMatrixStack,
         GLKMathDegreesToRadians(moonRotationAngleDegrees), 
         0.0, 1.0, 0.0);
      
      self.baseEffect.transform.modelviewMatrix = 
         GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
        
      [self.baseEffect prepareToDraw];

      // Draw triangles using vertices in the prepared vertex
      // buffers
      [AGLKVertexAttribArrayBuffer 
         drawPreparedArraysWithMode:GL_TRIANGLES
         startVertexIndex:0
         numberOfVertices:sphereNumVerts];
         
   GLKMatrixStackPop(self.modelviewMatrixStack);
   
   self.baseEffect.transform.modelviewMatrix = 
         GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
}


/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{  
   // Update the angles every frame to animate 
   // (one day every 60 display updates)
   self.earthRotationAngleDegrees += 360.0f / 60.0f;
   self.moonRotationAngleDegrees += (360.0f / 60.0f) / 
      SceneDaysPerMoonOrbit;
   
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

   [self drawEarth];
   [self drawMoon];
         
   [(AGLKContext *)view.context enable:GL_DEPTH_TEST];
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
   
   CFRelease(self.modelviewMatrixStack);
   self.modelviewMatrixStack = NULL;
}


/////////////////////////////////////////////////////////////////
// This method is called automatically and allows all standard 
// device orientations. 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != 
       UIInterfaceOrientationPortraitUpsideDown && 
       interfaceOrientation != 
       UIInterfaceOrientationPortrait);
}


/////////////////////////////////////////////////////////////////
// This method is called by a user interface object configured
// in Interface Builder.
- (IBAction)takeShouldUsePerspectiveFrom:(UISwitch *)aControl;
{
   GLfloat   aspectRatio = 
      (float)((GLKView *)self.view).drawableWidth /
      (float)((GLKView *)self.view).drawableHeight;
      
   if([aControl isOn])
   {
      self.baseEffect.transform.projectionMatrix = 
         GLKMatrix4MakeFrustum(
         -1.0 * aspectRatio, 
         1.0 * aspectRatio, 
         -1.0, 
         1.0, 
         1.0,
         120.0);  
   }
   else
   {
      self.baseEffect.transform.projectionMatrix = 
         GLKMatrix4MakeOrtho(
         -1.0 * aspectRatio, 
         1.0 * aspectRatio, 
         -1.0, 
         1.0, 
         1.0,
         120.0);  
   }
}

@end
