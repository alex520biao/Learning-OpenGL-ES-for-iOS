//
//  OpenGLES_Ch8_1ViewController.m
//  OpenGLES_Ch8_1
//

#import "OpenGLES_Ch8_1ViewController.h"
#import "AGLKContext.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModelManager.h"
#import "UtilityTextureInfo+viewAdditions.h"

@interface OpenGLES_Ch8_1ViewController ()

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) GLKSkyboxEffect *skyboxEffect;
@property (strong, nonatomic) GLKTextureInfo *textureInfo;
@property (assign, nonatomic, readwrite) GLKVector3 eyePosition;
@property (assign, nonatomic) GLKVector3 lookAtPosition;
@property (assign, nonatomic) GLKVector3 upVector;
@property (assign, nonatomic) float angle;
@property (strong, nonatomic) UtilityModelManager *modelManager;
@property (strong, nonatomic, strong) UtilityModel *boatModel;

@end


@implementation OpenGLES_Ch8_1ViewController

@synthesize baseEffect;
@synthesize skyboxEffect;
@synthesize textureInfo;
@synthesize eyePosition;
@synthesize lookAtPosition;
@synthesize upVector;
@synthesize angle;
@synthesize modelManager;
@synthesize boatModel;

#pragma mark - View lifecycle

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
   
   // Use high resolution depth buffer
   view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
         
   // Create an OpenGL ES 2.0 context and provide it to the
   // view
   view.context = [[AGLKContext alloc] 
      initWithAPI:kEAGLRenderingAPIOpenGLES2];
   
   // Make the new context current
   [EAGLContext setCurrentContext:view.context];
   
   // Create and configure base effect 
   self.baseEffect = [[GLKBaseEffect alloc] init];
   // Configure a light
   self.baseEffect.light0.enabled = GL_TRUE;
   self.baseEffect.light0.ambientColor = GLKVector4Make(
      0.9f, // Red 
      0.9f, // Green 
      0.9f, // Blue 
      1.0f);// Alpha 
   self.baseEffect.light0.diffuseColor = GLKVector4Make(
      1.0f, // Red 
      1.0f, // Green 
      1.0f, // Blue 
      1.0f);// Alpha       
   
   // Set initial point of view
   self.eyePosition = GLKVector3Make(0.0, 3.0, 3.0);
   self.lookAtPosition = GLKVector3Make(0.0, 0.0, 0.0);
   self.upVector = GLKVector3Make(0.0, 1.0, 0.0);
   
   // Load cubeMap texture
   NSString *path = [[NSBundle bundleForClass:[self class]]
      pathForResource:@"skybox0" ofType:@"png"];
   NSAssert(nil != path, @"Path to skybox image not found");   
   NSError *error = nil;
   self.textureInfo = [GLKTextureLoader 
      cubeMapWithContentsOfFile:path 
      options:nil 
      error:&error];
   
   // Create and configure skybox
   self.skyboxEffect = [[GLKSkyboxEffect alloc] init];
   self.skyboxEffect.textureCubeMap.name = self.textureInfo.name;
   self.skyboxEffect.textureCubeMap.target = 
      self.textureInfo.target;
   self.skyboxEffect.xSize = 6.0f;
   self.skyboxEffect.ySize = 6.0f;
   self.skyboxEffect.zSize = 6.0f;   

   // The model manager loads models and sends the data to GPU.
   // Each loaded model can be accesssed by name.
   NSString *modelsPath = [[NSBundle mainBundle] pathForResource:
      @"boat" ofType:@"modelplist"];
   self.modelManager = 
      [[UtilityModelManager alloc] initWithModelPath:modelsPath];
   
   // Load models used to draw the scene
   self.boatModel = [self.modelManager 
      modelNamed:@"boat"];
   NSAssert(nil != self.boatModel, 
      @"Failed to load boat model");
      
   // Cull back faces: Important! Many Sketchup models have back 
   // faces that cause Z fighting if back faces are not culled.
   [((AGLKContext *)view.context) enable:GL_CULL_FACE];
   
   [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];
}


/////////////////////////////////////////////////////////////////
// Called when the view controller's view has been unloaded
// Perform clean-up that is possible when you know the view 
// controller's view won't be asked to draw again soon.
- (void)viewDidUnload
{
   [super viewDidUnload];

   self.baseEffect = nil;
   self.skyboxEffect = nil;
   self.textureInfo = nil;
}


/////////////////////////////////////////////////////////////////
// Configure self.baseEffect's projection and modelview
// matrix for cinematic orbit around ship model.
- (void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio
{
   // Do this here instead of -viewDidLoad because we don't
   // yet know aspectRatio in -viewDidLoad.
   self.baseEffect.transform.projectionMatrix = 
      GLKMatrix4MakePerspective(
         GLKMathDegreesToRadians(85.0f),// Standard field of view
         aspectRatio,
         0.1f,   // Don't make near plane too close
         20.0f); // Far arbitrarily far enough to contain scene

   self.baseEffect.transform.modelviewMatrix =  
      GLKMatrix4MakeLookAt(
         self.eyePosition.x,      // Eye position
         self.eyePosition.y,
         self.eyePosition.z,
         self.lookAtPosition.x,   // Look-at position
         self.lookAtPosition.y,
         self.lookAtPosition.z,
         self.upVector.x,         // Up direction
         self.upVector.y,
         self.upVector.z);
   
   // Orbit slowly around ship model just to see the
   // scene change
   self.angle += 0.01;
   self.eyePosition = GLKVector3Make(
      3.0f * sinf(angle),
      3.0f,
      3.0f * cosf(angle));
      
   // Pitch up and down slowly to marvel at the sky and water
   self.lookAtPosition = GLKVector3Make(
      0.0, 
      1.5 + 3.0f * sinf(0.3 * angle),
      0.0);
}


/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
   // Calculate the aspect ratio for the scene and setup a 
   // perspective projection
   const GLfloat  aspectRatio = 
      (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
   
   // Clear back frame buffer colors (erase previous drawing)
   [(AGLKContext *)view.context clear:
      GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
   
   // Configure the point of view including animation
   [self preparePointOfViewWithAspectRatio:aspectRatio];
   
   // Set light position after change to point of view so that
   // light uses correct coordinate system.
   self.baseEffect.light0.position = GLKVector4Make(
      0.4f, 
      0.4f, 
      -0.3f,  
      0.0f);// Directional light
   
   // Draw skybox centered on eye position
   self.skyboxEffect.center = self.eyePosition;
   self.skyboxEffect.transform.projectionMatrix = 
      self.baseEffect.transform.projectionMatrix;
   self.skyboxEffect.transform.modelviewMatrix = 
      self.baseEffect.transform.modelviewMatrix;
   [self.skyboxEffect prepareToDraw];
   glDepthMask(false);
   [self.skyboxEffect draw];
   glBindVertexArrayOES(0);
   
   // Draw boat model 
   [self.modelManager prepareToDraw];
   [self.baseEffect prepareToDraw];   
   glDepthMask(true);
   [self.boatModel draw];
   
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


/////////////////////////////////////////////////////////////////
// This method is called automatically and allows all standard 
// device orientations. 
- (BOOL)shouldAutorotateToInterfaceOrientation:
   (UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != 
       UIInterfaceOrientationPortraitUpsideDown);
}

@end