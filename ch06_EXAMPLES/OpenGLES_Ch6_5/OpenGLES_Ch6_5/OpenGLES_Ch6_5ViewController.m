//
//  OpenGLES_Ch6_5ViewController.m
//  OpenGLES_Ch6_5
//

#import "OpenGLES_Ch6_5ViewController.h"
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

/////////////////////////////////////////////////////////////////
// Constants used to calculate the texture position of each 
// sub-image in a texture atlas that contains still frames from 
// a movie 
static const int numberOfMovieFrames = 51;
static const int numberOfMovieFramesPerRow = 8;
static const int numberOfMovieFramesPerColumn = 8;
static const int numberOfFramesPerSecond = 15;


@implementation OpenGLES_Ch6_5ViewController

@synthesize baseEffect;
@synthesize animatedMesh;
@synthesize canLightModel;
@synthesize spotLight0TiltAboutXAngleDeg;
@synthesize spotLight0TiltAboutZAngleDeg;
@synthesize spotLight1TiltAboutXAngleDeg;
@synthesize spotLight1TiltAboutZAngleDeg;
@synthesize shouldRipple;

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

   // Enable depth testing and blending with the frame buffer
   [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];
   [((AGLKContext *)view.context) enable:GL_BLEND];
   
   // Create and load the model for a can light
   self.canLightModel = [[SceneCanLightModel alloc] init];

   self.baseEffect.material.ambientColor = 
         GLKVector4Make(0.8f, 0.8f, 0.8f, 1.0f);
   self.baseEffect.lightModelAmbientColor = 
         GLKVector4Make(0.8f, 0.8f, 0.8f, 1.0f);

   // Light 0 is a spot light
   self.baseEffect.lightingType = GLKLightingTypePerVertex;
   self.baseEffect.lightModelTwoSided = GL_FALSE;
   self.baseEffect.lightModelAmbientColor = GLKVector4Make(
      0.6f, // Red 
      0.6f, // Green 
      0.6f, // Blue 
      1.0f);// Alpha 
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

   // Setup texture0
   CGImageRef imageRef0 = 
      [[UIImage imageNamed:@"RabbitTextureAtlas.png"] CGImage];
      
   GLKTextureInfo *textureInfo0 = [GLKTextureLoader 
      textureWithCGImage:imageRef0 
      options:nil 
      error:NULL];
      
   self.baseEffect.texture2d0.name = textureInfo0.name;
   self.baseEffect.texture2d0.target = textureInfo0.target;      
}


/////////////////////////////////////////////////////////////////
//  
- (void)updateSpotLightDirections
{
   // Tilt the spot lights using periodic functions for simple 
   // smooth animation
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
//  
- (void)updateTextureTransform
{
   // Calculate which sub-image of the texture atlas to use
   int      movieFrameNumber = 
      (int)floor(self.timeSinceLastResume * numberOfFramesPerSecond) %
         numberOfMovieFrames;
   
   // Calculate the position of the current sub-image
   GLfloat   currentRowPosition = 
      (movieFrameNumber % numberOfMovieFramesPerRow) *
      1.0f / numberOfMovieFramesPerRow; 
   GLfloat   currentColumnPosition = 
      (movieFrameNumber / numberOfMovieFramesPerColumn) *
      1.0f / numberOfMovieFramesPerColumn;

   // Translate to origin of current frame
   self.baseEffect.textureMatrix2d0 = 
      GLKMatrix4MakeTranslation(
         currentRowPosition,
         currentColumnPosition, 
         0.0f);
   // Scale to make current frame fills coordinate space 
   self.baseEffect.textureMatrix2d0 = 
      GLKMatrix4Scale(
          self.baseEffect.textureMatrix2d0,
          1.0f/numberOfMovieFramesPerRow,
          1.0f/numberOfMovieFramesPerColumn, 
          1.0f);
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
   self.baseEffect.texture2d0.enabled = GL_FALSE;
      
   [self.baseEffect prepareToDrawMultitextures];         
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
   self.baseEffect.texture2d0.enabled = GL_FALSE;
   
   [self.baseEffect prepareToDrawMultitextures];         
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
   [self updateSpotLightDirections];
   [self updateTextureTransform];

   // Clear back frame buffer (erase previous drawing)
   [((AGLKContext *)view.context) 
      clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
   
   // Calculate the aspect ratio for the scene and setup a 
   // perspective projection
   const GLfloat  aspectRatio = 
      (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
   
   self.baseEffect.transform.projectionMatrix = 
      GLKMatrix4MakePerspective(
         GLKMathDegreesToRadians(80.0f),// Wide field of view
         aspectRatio,
         0.1f,   // Don't make near plane too close
         255.0f);// Far is arbitrarily far enough to contain scene
   self.baseEffect.transform.projectionMatrix = 
      GLKMatrix4Rotate(
          self.baseEffect.transform.projectionMatrix,
          GLKMathDegreesToRadians(-90.0f),
          0.0f,
          0.0f, 
          1.0f);
   
   // Draw lights
   [self drawLight0];
   [self drawLight1];
   
   if(shouldRipple)
   {
      [self.animatedMesh updateMeshWithElapsedTime:
         self.timeSinceLastResume];
   }
   self.baseEffect.texture2d0.enabled = GL_TRUE;
   
   // Draw the mesh
   [self.baseEffect prepareToDrawMultitextures];         
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


/////////////////////////////////////////////////////////////////
// This method is called by a UISwitch in the user interface
- (IBAction)takeShouldRippleFrom:(UISwitch *)sender;
{
   self.shouldRipple = [sender isOn];
   
   if(!self.shouldRipple)
   {
      [self.animatedMesh updateMeshWithDefaultPositions];
   }
}

@end
