//
//  OpenGLES_Ch8_4ViewController.m
//  OpenGLES_Ch8_4
//

#import "OpenGLES_Ch8_4ViewController.h"
#import "AGLKContext.h"
#import "UtilityBillboardManager+viewAdditions.h"
#import "UtilityBillboard.h"
#import "UtilityModelManager.h"
#import "UtilityModel+viewAdditions.h"

@interface OpenGLES_Ch8_4ViewController ()
{
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) 
   UtilityBillboardManager *billboardManager;
@property (assign, nonatomic, readwrite) GLKVector3 eyePosition;
@property (assign, nonatomic) GLKVector3 lookAtPosition;
@property (assign, nonatomic) GLKVector3 upVector;
@property (assign, nonatomic) float angle;
@property (strong, nonatomic) UtilityModelManager *modelManager;
@property (strong, nonatomic, strong) UtilityModel *parkModel;
@property (strong, nonatomic, strong) UtilityModel *cylinderModel;

- (void)addBillboardTrees;

@end


@implementation OpenGLES_Ch8_4ViewController

@synthesize baseEffect;
@synthesize billboardManager;
@synthesize eyePosition;
@synthesize lookAtPosition;
@synthesize upVector;
@synthesize angle;
@synthesize modelManager;
@synthesize parkModel;
@synthesize cylinderModel;

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
   
   // The model manager loads models and sends the data to GPU.
   // Each loaded model can be accessed by name.
   NSString *modelsPath = [[NSBundle mainBundle] pathForResource:
      @"park" ofType:@"modelplist"];
   self.modelManager = 
      [[UtilityModelManager alloc] initWithModelPath:modelsPath];
   
   // Load models used to draw the scene
   self.parkModel = [self.modelManager 
      modelNamed:@"park"];
   NSAssert(nil != self.parkModel, 
      @"Failed to load park model");
   self.cylinderModel = [self.modelManager 
      modelNamed:@"cylinder"];
   NSAssert(nil != self.cylinderModel, 
      @"Failed to load cylinder model");
         
   // Add billboards to demo
   [self addBillboardTrees];
   
   // Set initial point of view
   self.eyePosition = GLKVector3Make(15, 8, 15);
   self.lookAtPosition = GLKVector3Make(0.0, 0.0, 0.0);
   self.upVector = GLKVector3Make(0.0, 1.0, 0.0);
   
   // Set other persistent context state
   [(AGLKContext *)view.context setClearColor:
      GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f)];
   [(AGLKContext *)view.context enable:GL_DEPTH_TEST];
   [(AGLKContext *)view.context enable:GL_BLEND];
   [(AGLKContext *)view.context 
      setBlendSourceFunction:GL_SRC_ALPHA 
      destinationFunction:GL_ONE_MINUS_SRC_ALPHA];
      
   // Cull back faces: Important! Many Sketchup models have back 
   // faces that cause Z fighting if back faces are not culled.
   [((AGLKContext *)view.context) enable:GL_CULL_FACE];

   // Create and configure base effect 
   self.baseEffect = [[GLKBaseEffect alloc] init];
   // Configure a light
   self.baseEffect.light0.enabled = GL_TRUE;
   self.baseEffect.light0.ambientColor = GLKVector4Make(
      0.8f, // Red 
      0.8f, // Green 
      0.8f, // Blue 
      1.0f);// Alpha 
   self.baseEffect.light0.diffuseColor = GLKVector4Make(
      0.9f, // Red 
      0.9f, // Green 
      0.9f, // Blue 
      1.0f);// Alpha 
   self.baseEffect.texture2d0.name = 
      self.modelManager.textureInfo.name;
   self.baseEffect.texture2d0.target = 
      self.modelManager.textureInfo.target;
}


/////////////////////////////////////////////////////////////////
// Called when the view controller's view has been unloaded
// Perform clean-up that is possible when you know the view 
// controller's view won't be asked to draw again soon.
- (void)viewDidUnload
{
   [super viewDidUnload];

   self.baseEffect = nil;
   self.billboardManager = nil;
   self.parkModel = nil;
   self.cylinderModel = nil;
}


/////////////////////////////////////////////////////////////////
// Configure self.baseEffect's projection and model-view
// matrix for cinematic orbit around ship model.
- (void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio
{
   // Do this here instead of -viewDidLoad because we don't
   // yet know aspectRatio in -viewDidLoad.
   self.baseEffect.transform.projectionMatrix = 
      GLKMatrix4MakePerspective(
         GLKMathDegreesToRadians(85.0f),// Standard field of view
         aspectRatio,
         0.5f,    // Don't make near plane too close
         200.0f); // Far arbitrarily far enough to contain scene

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
   
   self.angle += 0.01;
   self.eyePosition = GLKVector3Make(
      15.0f * sinf(angle),
      18.0f + 5.0f * sinf(0.3f * angle),
      15.0f * cosf(angle));
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
      0.2f,  
      0.0f);// Directional light
   
   [self.modelManager prepareToDraw];
   [self.parkModel draw];
   
   const GLKMatrix4 savedModelview = 
      self.baseEffect.transform.modelviewMatrix;
   const GLKMatrix4 translationModelview = 
      GLKMatrix4Translate(savedModelview, -5.0f, 0.0f, -5.0f);
      
   if(YES == self.billboardManager.shouldRenderSpherical)
   {
      // Translate to cylinder position and multiply transpose
      // of rotation components from modelview
      GLKMatrix4 rotationModelview = translationModelview;
      rotationModelview.m30 = 0.0f;
      rotationModelview.m31 = 0.0f;
      rotationModelview.m32 = 0.0f;
      rotationModelview = GLKMatrix4Transpose(rotationModelview);
      self.baseEffect.transform.modelviewMatrix = 
         GLKMatrix4Multiply(translationModelview, 
            rotationModelview);
      [self.baseEffect prepareToDraw];   
      [self.cylinderModel draw];
   }
   else
   {  // Translate to cylinder position
      self.baseEffect.transform.modelviewMatrix = 
         translationModelview;
      [self.baseEffect prepareToDraw];   
      [self.cylinderModel draw];
   }
   // Restore modelview matrix
   self.baseEffect.transform.modelviewMatrix = savedModelview;
   [self.baseEffect prepareToDraw];   
   
   const GLKVector3 lookDirection = 
      GLKVector3Subtract(self.lookAtPosition, self.eyePosition);
      
   [self.billboardManager updateWithEyePosition:self.eyePosition 
      lookDirection:lookDirection];
   [self.billboardManager drawWithEyePosition:self.eyePosition 
      lookDirection:lookDirection 
      upVector:self.upVector];
      
   {  // Log any errors 
      GLenum error = glGetError();
      if(GL_NO_ERROR != error)
      {
         NSLog(@"GL Error: 0x%x", error);
      }
   }
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


/////////////////////////////////////////////////////////////////
// Add billboards with translucent textures that look like trees.
// The selection of textures is arbitrarily chosen to provide
// variety in the rendered scene.
// The placement of billboards corresponds with the "park" model
// used in the example.
- (void)addBillboardTrees
{
   if(nil == self.billboardManager)
   {
      self.billboardManager = 
         [[UtilityBillboardManager alloc] init];
   }
   
   for(int j = -4; j < 4; j++)
   {
      for(int i = -4; i < 4; i++)
      {
         const NSInteger treeIndex = random() % 2;
         const GLfloat minTextureT = treeIndex * 0.25f;
         
         [self.billboardManager 
            addBillboardAtPosition:GLKVector3Make(
               i * -10.0f - 5.0f, 
               0.0, 
               j * -10.0f - 5.0f)
            size:GLKVector2Make(8.0f, 8.0f)
            minTextureCoords:GLKVector2Make(
               3.0f/8.0f, 
               1.0f - minTextureT)
            maxTextureCoords:GLKVector2Make(
               7.0f/8.0f, 
               1.0f - (minTextureT + 0.25f))];
      }
   }
}


/////////////////////////////////////////////////////////////////
// Called by user interface object
- (IBAction)takeShouldRenderSpherical:(UISwitch *)sender;
{
   self.billboardManager.shouldRenderSpherical =
      [sender isOn];
}

@end
