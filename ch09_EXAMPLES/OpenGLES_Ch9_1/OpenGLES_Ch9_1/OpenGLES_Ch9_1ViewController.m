//
//  OpenGLES_Ch9_1ViewController.m
//  OpenGLES_Ch9_1
//

#import "OpenGLES_Ch9_1ViewController.h"
#import "OpenGLES_Ch9_1AppDelegate.h"
#import "UtilityModelManager.h"
#import "UtilityModel+viewAdditions.h"
#import "AGLKContext.h"
#import "AGLKFrustum.h"

@interface OpenGLES_Ch9_1ViewController ()

@property (strong, nonatomic) UtilityModelManager *modelManager;
@property (strong, nonatomic) UtilityModel *model;
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (assign, nonatomic) float filteredFPS;
@property (assign, nonatomic) AGLKFrustum frustum;
@property (assign, nonatomic) BOOL orientationDidChange;
@property (assign, nonatomic) BOOL shouldCull;
@property (assign, nonatomic) float yawAngleRad;

@end


@implementation OpenGLES_Ch9_1ViewController

@synthesize fpsField = fpsField_;
@synthesize modelManager = modelManager_;
@synthesize model = model_;
@synthesize baseEffect = baseEffect_;
@synthesize filteredFPS = filteredFPS_;
@synthesize frustum = frustum_;
@synthesize orientationDidChange = orientationDidChange_;
@synthesize shouldCull = shouldCull_;
@synthesize yawAngleRad = yawAngleRad_;


#pragma mark - View lifecycle

/////////////////////////////////////////////////////////////////
// Called when the view controller's view is loaded
// Perform initialization before the view is asked to draw
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   // Cull by default
   self.shouldCull = YES;
   
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
   
   // Make the new context current and enable depth testing 
   [AGLKContext setCurrentContext:view.context];
   [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];

   // Cull back faces
   [((AGLKContext *)view.context) enable:GL_CULL_FACE];
   
   // Create a base effect that provides standard OpenGL ES 2.0
   // shading language programs and set constants to be used for 
   // all subsequent rendering
   self.baseEffect = [[GLKBaseEffect alloc] init];
   
   // Configure a light
   self.baseEffect.light0.ambientColor = GLKVector4Make(
      0.7f, // Red 
      0.7f, // Green 
      0.7f, // Blue 
      1.0f);// Alpha 
   self.baseEffect.light0.diffuseColor = GLKVector4Make(
      1.0f, // Red 
      1.0f, // Green 
      1.0f, // Blue 
      1.0f);// Alpha       
   self.baseEffect.light0.position = GLKVector4Make(
      1.0f, 
      0.8f, 
      0.4f,
      0.0f);  // Directional light
    
   // Set the background color  
   ((AGLKContext *)view.context).clearColor = GLKVector4Make(
      0.0f, // Red 
      0.0f, // Green 
      0.0f, // Blue 
      1.0f);// Alpha 
   
   // The model manager loads models and sends the data to GPU.
   // Each loaded model can be accessed by name.
   NSString *modelsPath = [[NSBundle mainBundle] pathForResource:
      @"starships" ofType:@"modelplist"];
   if(nil != modelsPath)
   {
      self.modelManager = 
         [[UtilityModelManager alloc] initWithModelPath:
         modelsPath];
   }
   
   // Load models used to draw the scene
   self.model = [self.modelManager 
      modelNamed:@"starship2"];
   NSAssert(nil != self.model, 
      @"Failed to load model");
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

   self.baseEffect = nil;
   self.model = nil;
}


/////////////////////////////////////////////////////////////////
// This method is called automatically at the update rate of the 
// receiver.
- (void)update
{
   const NSTimeInterval elapsedTime = [self timeSinceLastUpdate];
   
   if(0.0 < elapsedTime)
   {
      const float unfilteredFPS = 1.0f / elapsedTime;
         
      // add part of the difference between current filtered FPS
      // and unfilteredFPS (simple low pass filter)
      self.filteredFPS += 0.2f * 
         (unfilteredFPS - self.filteredFPS);
   }
   
   self.fpsField.text = [NSString stringWithFormat:@"%03.1f FPS",
      self.filteredFPS];
}


/////////////////////////////////////////////////////////////////
// Updates the receiver's baseEffect modelview and projection
// matrices based on device orientation.
- (void)calculateMatricesAndFrustumInView:(GLKView *)view
{
   if(self.orientationDidChange ||
      !AGLKFrustumHasDimention(&frustum_))
   {
      // Calculate the aspect ratio for the scene and setup an 
      // arbitrary perspective projection
      const GLfloat  aspectRatio = (GLfloat)view.drawableWidth /
         (GLfloat)view.drawableHeight;
      const GLfloat fieldOfViewDeg = 7.0f; // Very narrow field
      const GLfloat nearDistance = 1.0f; 
      const GLfloat farDistance = 10000.0f;
      const GLfloat fieldOfViewRad = 
         GLKMathDegreesToRadians(fieldOfViewDeg);
      
      // Initialize the frustum with same perspective parameters
      // used by GLKMatrix4MakePerspective()
      self.frustum = AGLKFrustumMakeFrustumWithParameters(
         fieldOfViewRad, 
         aspectRatio, 
         nearDistance, 
         farDistance);

      // Set the base effect's projection matrix to match frustum
      self.baseEffect.transform.projectionMatrix = 
         AGLKFrustumMakePerspective(&frustum_);
   }
   
   // Use motion capture if available to pan around the scene
   // demonstrating continuously changing viewing frustum
   CMMotionManager *motionManager = 
      [(OpenGLES_Ch9_1AppDelegate *)[
         [UIApplication sharedApplication] delegate] 
      motionManager];
   CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
   
   if(nil != deviceMotion)
   {  // Use high resolution device motion capture
      self.yawAngleRad = deviceMotion.attitude.yaw;
   }
   else
   {  // Use arbitrary rotation rate just to animate scene
      self.yawAngleRad = 0.1f * [self timeSinceLastResume];
   }
   
   // Use reasonable eye position and up direction
   static const GLKVector3 eyePosition = {
      0.0, 5.0, 0.0
   };
   static const GLKVector3 upDirection = {
      0.0, 1.0, 0.0
   };
   
   // Calculate current look-at position
   const GLKVector3 lookAtPosition = {
      100.0f * sinf(self.yawAngleRad),
      0.0, 
      100.0f * cosf(self.yawAngleRad)
   };
   
   // Configure the frustum field of view with same parameters 
   // used by GLKMatrix4MakeLookAt()
   AGLKFrustumSetPositionAndDirection(
      &frustum_, 
      eyePosition, 
      lookAtPosition, 
      upDirection);
      
   // Set the base effect's modelview matrix to match frustum
   self.baseEffect.transform.modelviewMatrix =  
      AGLKFrustumMakeModelview(&frustum_); 
}


/////////////////////////////////////////////////////////////////
// Draw models positioned throughout the scene
- (void)drawModels
{  
   const float modelRadius = 7.33f; // Used to cull models
      
   self.baseEffect.texture2d0.name = 
      self.modelManager.textureInfo.name;
   self.baseEffect.texture2d0.target = 
      self.modelManager.textureInfo.target;

   [self.modelManager prepareToDraw];
   
   // Draw an arbitary large number of models 
   for(NSInteger i = -4; i < 5; i++)
   {
      for(NSInteger j = -4; j < 5; j++)
      {
         const GLKVector3 modelPosition = {
            -100.0f + 150.0f * i, 
            0.0f, 
            -100.0f + 150.0f * j
         };
         
         if(!self.shouldCull ||
            AGLKFrustumOut != AGLKFrustumCompareSphere(
               &frustum_, modelPosition, modelRadius))
         {
            // Savethe current matrix
            GLKMatrix4 savedMatrix = 
               self.baseEffect.transform.modelviewMatrix;
            
            // Translate to the model position
            self.baseEffect.transform.modelviewMatrix =  
               GLKMatrix4Translate(savedMatrix, 
                  modelPosition.x, 
                  modelPosition.y, 
                  modelPosition.z); 
            [self.baseEffect prepareToDraw];
            
            // Draw the model
            [self.model draw];
            
            // Restore the saved matrix
            self.baseEffect.transform.modelviewMatrix =
               savedMatrix;
         }
      }
   }
}

    
/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{      
   // Clear back frame buffer (erase previous drawing)
   // and depth buffer
   [((AGLKContext *)view.context) 
      clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
   
   [self calculateMatricesAndFrustumInView:view];
   [self drawModels];
   
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
   BOOL result = NO;
   
    // Return YES for supported orientations
   if ([[UIDevice currentDevice] userInterfaceIdiom] == 
      UIUserInterfaceIdiomPhone)
   {
       result = (interfaceOrientation != 
          UIInterfaceOrientationPortraitUpsideDown);
   } 
   else 
   {
       result = YES;
   }
   
   self.orientationDidChange = result;
   
   return result;
}


/////////////////////////////////////////////////////////////////
// This action method is called by a user interface switch 
// configured in Interface Builder 
- (IBAction)takeShouldCullFrom:(UISwitch *)sender;
{
   self.shouldCull = sender.isOn;
}


@end
