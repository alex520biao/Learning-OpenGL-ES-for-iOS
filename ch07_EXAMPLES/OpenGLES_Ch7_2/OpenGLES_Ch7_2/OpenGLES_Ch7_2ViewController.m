//
//  OpenGLES_Ch7_2ViewController.m
//  OpenGLES_Ch7_2
//

#import "OpenGLES_Ch7_2ViewController.h"
#import "UtilityModelManager.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModel+skinning.h"
#import "UtilityModelManager+skinning.h"
#import "UtilityJoint.h"
#import "UtilityArmatureBaseEffect.h"
#import "AGLKContext.h"


@interface OpenGLES_Ch7_2ViewController ()

@property (strong, nonatomic) UtilityModelManager *modelManager;
@property (strong, nonatomic) UtilityArmatureBaseEffect 
   *baseEffect;
@property (strong, nonatomic) UtilityModel *bone0;
@property (strong, nonatomic) UtilityModel *bone1;
@property (strong, nonatomic) UtilityModel *bone2;
@property (assign, nonatomic) float joint0AngleRadians;
@property (assign, nonatomic) float joint1AngleRadians;
@property (assign, nonatomic) float joint2AngleRadians;

@end


@implementation OpenGLES_Ch7_2ViewController

@synthesize modelManager;
@synthesize baseEffect;
@synthesize bone0;
@synthesize bone1;
@synthesize bone2;
@synthesize joint0AngleRadians;
@synthesize joint1AngleRadians;
@synthesize joint2AngleRadians;


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
   
   // Make the new context current andenable depth testing 
   [AGLKContext setCurrentContext:view.context];
   [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];

   // Create a base effect that provides standard OpenGL ES 2.0
   // shading language programs and set constants to be used for 
   // all subsequent rendering
   self.baseEffect = [[UtilityArmatureBaseEffect alloc] init];
   
   // Configure a light
   self.baseEffect.light0.enabled = GL_TRUE;
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
   self.baseEffect.light0Position = GLKVector4Make(
      1.0f, 
      0.8f, 
      0.4f,  
      0.0f);// Directional light
    
   // Set the background color  
   ((AGLKContext *)view.context).clearColor = GLKVector4Make(
      0.0f, // Red 
      0.0f, // Green 
      0.0f, // Blue 
      1.0f);// Alpha 
   
   // The model manager loads models and sends the data to GPU.
   // Each loaded model can be accesssed by name.
   NSString *modelsPath = [[NSBundle mainBundle] pathForResource:
      @"armature" ofType:@"modelplist"];
   if(nil != modelsPath)
   {
      self.modelManager = 
         [[UtilityModelManager alloc] initWithModelPath:
            modelsPath];
   }
   
   // Load models used to draw the Utility
   self.bone0 = [self.modelManager 
      modelNamed:@"bone0"];
   NSAssert(nil != self.bone0, 
      @"Failed to load bone0 model");
   [self.bone0 assignJoint:0];
   
   self.bone1 = [self.modelManager 
      modelNamed:@"bone1"];
   NSAssert(nil != self.bone1, 
      @"Failed to load bone1 model");
   [self.bone1 assignJoint:1];
   
   self.bone2 = [self.modelManager 
      modelNamed:@"bone2"];
   NSAssert(nil != self.bone2, 
      @"Failed to load bone2 model");
   [self.bone2 assignJoint:2];

   // Create collection of joints
   UtilityJoint *bone0Joint = [[UtilityJoint alloc]
      initWithDisplacement:GLKVector3Make(0, 0, 0)
      parent:nil];
   float bone0Length = self.bone0.axisAlignedBoundingBox.max.y -
      self.bone0.axisAlignedBoundingBox.min.y;
   UtilityJoint *bone1Joint = [[UtilityJoint alloc]
      initWithDisplacement:GLKVector3Make(0, bone0Length, 0)
      parent:bone0Joint];
   float bone1Length = self.bone1.axisAlignedBoundingBox.max.y -
      self.bone1.axisAlignedBoundingBox.min.y;
   UtilityJoint *bone2Joint = [[UtilityJoint alloc]
      initWithDisplacement:GLKVector3Make(0, bone1Length, 0)
      parent:bone1Joint];
      
   baseEffect.jointsArray = [NSArray arrayWithObjects:
      bone0Joint,
      bone1Joint,
      bone2Joint,
      nil];
   
   // Set initial point of view to reasonable arbitrary values
   // These values make most of the simulated rink visible
   self.baseEffect.transform.modelviewMatrix =  
      GLKMatrix4MakeLookAt(
         5.0, 10.0, 15.0,// Eye position
         0.0, 2.0, 0.0,  // Look-at position
         0.0, 1.0, 0.0); // Up direction

   // Start armature joints in default positions
   [self setJoint0AngleRadians:0];
   [self setJoint1AngleRadians:0];
   [self setJoint2AngleRadians:0];
}


/////////////////////////////////////////////////////////////////
// This method is called automatically at the update rate of the 
// receiver (default 30 Hz).
- (void)update
{
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
   
   // Cull back faces: Important! many Sketchup models have back 
   // faces that cause Z fighting if back faces are not culled.
   [((AGLKContext *)view.context) enable:GL_CULL_FACE];
   
   // Calculate the aspect ratio for the Utility and setup a 
   // perspective projection
   const GLfloat  aspectRatio = 
      (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
   
   self.baseEffect.transform.projectionMatrix = 
      GLKMatrix4MakePerspective(
         GLKMathDegreesToRadians(35.0f),// Standard field of view
         aspectRatio,
         4.0f,   // Don't make near plane too close
         20.0f); // Far arbitrarily far enough to contain Utility
      
   [self.modelManager prepareToDrawWithJointInfluence];
   [self.baseEffect prepareToDrawArmature];
   
   // Draw the bones
   [self.bone0 draw];
   [self.bone1 draw];
   [self.bone2 draw];
      
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

   baseEffect = nil;
   bone0 = nil;
   bone1 = nil;
   bone2 = nil;
}


/////////////////////////////////////////////////////////////////
// This method is called automatically and allows all standard 
// device orientations. 
- (BOOL)shouldAutorotateToInterfaceOrientation:
   (UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
   if ([[UIDevice currentDevice] userInterfaceIdiom] == 
      UIUserInterfaceIdiomPhone) 
   {
      return (interfaceOrientation != 
         UIInterfaceOrientationPortraitUpsideDown);
   } 
   else 
   {
       return YES;
   }
}


/////////////////////////////////////////////////////////////////
//  
- (void)setJoint0AngleRadians:(float)value
{
   joint0AngleRadians = value;
   
   GLKMatrix4  rotateZMatrix = GLKMatrix4MakeRotation(
      value * M_PI * 0.5, 0, 0, 1);
   
   [(UtilityJoint *)[baseEffect.jointsArray objectAtIndex:0] 
      setMatrix:rotateZMatrix];
}


/////////////////////////////////////////////////////////////////
//  
- (void)setJoint1AngleRadians:(float)value
{
   joint1AngleRadians = value;
   
   GLKMatrix4  rotateZMatrix = GLKMatrix4MakeRotation(
      value * M_PI * 0.5, 0, 0, 1);
   
   [(UtilityJoint *)[baseEffect.jointsArray objectAtIndex:1] 
      setMatrix:rotateZMatrix];
}


/////////////////////////////////////////////////////////////////
//  
- (void)setJoint2AngleRadians:(float)value
{
   joint2AngleRadians = value;
   
   GLKMatrix4  rotateZMatrix = GLKMatrix4MakeRotation(
      value * M_PI * 0.5, 0, 0, 1);
   
   [(UtilityJoint *)[baseEffect.jointsArray objectAtIndex:2] 
      setMatrix:rotateZMatrix];
}


/////////////////////////////////////////////////////////////////
//  
- (IBAction)takeAngle0From:(UISlider *)sender
{
   [self setJoint0AngleRadians:[sender value]];
}


/////////////////////////////////////////////////////////////////
//  
- (IBAction)takeAngle1From:(UISlider *)sender
{
   [self setJoint1AngleRadians:[sender value]];
}


/////////////////////////////////////////////////////////////////
//  
- (IBAction)takeAngle2From:(UISlider *)sender
{
   [self setJoint2AngleRadians:[sender value]];
}

@end
