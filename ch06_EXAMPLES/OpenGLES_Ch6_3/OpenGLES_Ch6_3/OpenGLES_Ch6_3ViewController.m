//
//  OpenGLES_Ch6_3ViewController.m
//  OpenGLES_Ch6_3
//

#import "OpenGLES_Ch6_3ViewController.h"
#import "AGLKContext.h"
#import "AGLKTextureTransformBaseEffect.h"
#import "SceneAnimatedMesh.h"
#import "SceneCanLightModel.h"


// Positions of light sources
static const GLKVector4 spotLight0Position = 
   {10.0f, 18.0f, -10.0f, 1.0f};
static const GLKVector4 spotLight1Position = 
   {30.0f, 18.0f, -10.0f, 1.0f};
static const GLKVector4 light2Position = 
   {1.0f, 0.5f, 0.0f, 0.0f};


@implementation OpenGLES_Ch6_3ViewController

@synthesize baseEffect;
@synthesize animatedMesh;
@synthesize canLightModel;
@synthesize spotLight0TiltAboutXAngleDeg;
@synthesize spotLight0TiltAboutZAngleDeg;
@synthesize spotLight1TiltAboutXAngleDeg;
@synthesize spotLight1TiltAboutZAngleDeg;

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
   view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
   
   // Make the new context current
   [AGLKContext setCurrentContext:view.context];
   
   // Create a base effect that provides standard OpenGL ES 2.0
   // shading language programs and set constants to be used for 
   // all subsequent rendering
   self.baseEffect = [[AGLKTextureTransformBaseEffect alloc] init];

   // Use high quality lighting (important for spot lights)
   self.baseEffect.lightingType = GLKLightingTypePerPixel;
   self.baseEffect.lightModelTwoSided = GL_FALSE;
   self.baseEffect.lightModelAmbientColor = GLKVector4Make(
      0.6f, // Red 
      0.6f, // Green 
      0.6f, // Blue 
      1.0f);// Alpha 
   
   // Set the background color stored in the current context 
   ((AGLKContext *)view.context).clearColor = GLKVector4Make(
      0.0f, // Red 
      0.0f, // Green 
      0.0f, // Blue 
      1.0f);// Alpha 
   
   // Create a mesh to animate
   animatedMesh = [[SceneAnimatedMesh alloc] init];

   // set the modelview matrix to match current eye and look-at 
   // positions
   self.baseEffect.transform.modelviewMatrix =  
      GLKMatrix4MakeLookAt(
         20, 25, 5, 
         20, 0, -15, 
         0, 1, 0);

   glEnable(GL_DEPTH_TEST);
   
   // Create and load the model for a can light
   self.canLightModel = [[SceneCanLightModel alloc] init];

   self.baseEffect.material.ambientColor = 
         GLKVector4Make(0.4f, 0.4f, 0.4f, 1.0f);
   self.baseEffect.lightModelAmbientColor = 
         GLKVector4Make(0.4f, 0.4f, 0.4f, 1.0f);

   // Light 0 is a spot light
   self.baseEffect.light0.enabled = GL_TRUE;
   self.baseEffect.light0.spotExponent = 20.0f;
   self.baseEffect.light0.spotCutoff = 30.0f;         
   self.baseEffect.light0.diffuseColor = GLKVector4Make(
      1.0f, // Red 
      1.0f, // Green 
      0.0f, // Blue 
      1.0f);// Alpha 
   self.baseEffect.light0.specularColor = GLKVector4Make(
      0.0f, // Red 
      0.0f, // Green 
      0.0f, // Blue 
      1.0f);// Alpha
   
   // Light 1 is a spot light
   self.baseEffect.light1.enabled = GL_TRUE;
   self.baseEffect.light1.spotExponent = 20.0f;
   self.baseEffect.light1.spotCutoff = 30.0f;         
   self.baseEffect.light1.diffuseColor = GLKVector4Make(
      0.0f, // Red 
      1.0f, // Green 
      1.0f, // Blue 
      1.0f);// Alpha 
   self.baseEffect.light1.specularColor = GLKVector4Make(
      0.0f, // Red 
      0.0f, // Green 
      0.0f, // Blue 
      1.0f);// Alpha

   // Light 2 is directional
   self.baseEffect.light2.enabled = GL_TRUE;
   self.baseEffect.light2Position = light2Position;
   self.baseEffect.light2.diffuseColor = GLKVector4Make(
      0.5f, // Red 
      0.5f, // Green 
      0.5f, // Blue 
      1.0f);// Alpha 
   
   // Material colors
   self.baseEffect.material.diffuseColor = GLKVector4Make(
      1.0f, // Red 
      1.0f, // Green 
      1.0f, // Blue 
      1.0f);// Alpha 
   self.baseEffect.material.specularColor = GLKVector4Make(
      0.0f, // Red 
      0.0f, // Green 
      0.0f, // Blue 
      1.0f);// Alpha 
}


/////////////////////////////////////////////////////////////////
//  
- (void)updateSpotLightDirections
{
   // Tilt the spot lights using periodic functions for simple 
   // smooth animation (constants are arbitrary and chosen for
   // visually interesting spot light directions)
   spotLight0TiltAboutXAngleDeg = -20.0f + 30.0f * sinf(
      self.timeSinceLastResume);
   spotLight0TiltAboutZAngleDeg = 30.0f * cosf(
      self.timeSinceLastResume);
   spotLight1TiltAboutXAngleDeg = 20.0f + 30.0f * cosf(
      self.timeSinceLastResume);
   spotLight1TiltAboutZAngleDeg = 30.0f * sinf(
      self.timeSinceLastResume);
}


/////////////////////////////////////////////////////////////////
// This method is called automatically at the update rate of the 
// receiver (default 30 Hz).
- (void)update
{
   [self updateSpotLightDirections];
}


/////////////////////////////////////////////////////////////////
// 
- (void)drawLight0
{
   // Save effect attributes that will be changed
   GLKMatrix4  savedModelviewMatrix = 
      self.baseEffect.transform.modelviewMatrix;

   // Translate to the model's position
   self.baseEffect.transform.modelviewMatrix = 
      GLKMatrix4Translate(savedModelviewMatrix,
          spotLight0Position.x, 
          spotLight0Position.y, 
          spotLight0Position.z);
   self.baseEffect.transform.modelviewMatrix = 
      GLKMatrix4Rotate(
          self.baseEffect.transform.modelviewMatrix,
          GLKMathDegreesToRadians(self.spotLight0TiltAboutXAngleDeg),
          1, 
          0, 
          0);
   self.baseEffect.transform.modelviewMatrix = 
      GLKMatrix4Rotate(
          self.baseEffect.transform.modelviewMatrix,
          GLKMathDegreesToRadians(self.spotLight0TiltAboutZAngleDeg),
          0, 
          0, 
          1);
          
   // Configure light in current coordinate system
   self.baseEffect.light0Position = GLKVector4Make(0, 0, 0, 1);   
   self.baseEffect.light0SpotDirection = GLKVector3Make(0, -1, 0);
   
   [self.baseEffect prepareToDraw];         
   [self.canLightModel draw];

   // Restore saved attributes   
   self.baseEffect.transform.modelviewMatrix = 
      savedModelviewMatrix;
}


/////////////////////////////////////////////////////////////////
// 
- (void)drawLight1
{
   // Save effect attributes that will be changed
   GLKMatrix4  savedModelviewMatrix = 
      self.baseEffect.transform.modelviewMatrix;

   // Translate to the model's position
   self.baseEffect.transform.modelviewMatrix = 
      GLKMatrix4Translate(savedModelviewMatrix,
          spotLight1Position.x, 
          spotLight1Position.y, 
          spotLight1Position.z);
   self.baseEffect.transform.modelviewMatrix = 
      GLKMatrix4Rotate(
          self.baseEffect.transform.modelviewMatrix,
          GLKMathDegreesToRadians(self.spotLight1TiltAboutXAngleDeg),
          1, 
          0, 
          0);
   self.baseEffect.transform.modelviewMatrix = 
      GLKMatrix4Rotate(
          self.baseEffect.transform.modelviewMatrix,
          GLKMathDegreesToRadians(self.spotLight1TiltAboutZAngleDeg),
          0, 
          0, 
          1);
          
   // Configure light in current coordinate system
   self.baseEffect.light1Position = GLKVector4Make(0, 0, 0, 1);   
   self.baseEffect.light1SpotDirection = GLKVector3Make(0, -1, 0);
   
   [self.baseEffect prepareToDraw];         
   [self.canLightModel draw];

   // Restore saved attributes   
   self.baseEffect.transform.modelviewMatrix = 
      savedModelviewMatrix;
}


/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{  
   // Clear back frame buffer (erase previous drawing)
   [((AGLKContext *)view.context) 
      clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
   
   // Calculate the aspect ratio for the scene and setup a 
   // perspective projection
   const GLfloat  aspectRatio = 
      (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
   
   self.baseEffect.transform.projectionMatrix = 
      GLKMatrix4MakePerspective(
         GLKMathDegreesToRadians(60.0f),// Standard field of view
         aspectRatio,
         0.1f,   // Don't make near plane too close
         255.0f);// Far is arbitrarily far enough to contain scene
   
   // Draw lights
   [self drawLight0];
   [self drawLight1];
   
   [self.animatedMesh updateMeshWithElapsedTime:
      self.timeSinceLastResume];
   
   // Draw the mesh
   [self.baseEffect prepareToDraw];         
   [self.animatedMesh prepareToDraw];
   [self.animatedMesh drawEntireMesh];
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
    
   // Stop using the context created in -viewDidLoad
   ((GLKView *)self.view).context = nil;
   [EAGLContext setCurrentContext:nil];

   animatedMesh = nil;
   canLightModel = nil;
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

@end
