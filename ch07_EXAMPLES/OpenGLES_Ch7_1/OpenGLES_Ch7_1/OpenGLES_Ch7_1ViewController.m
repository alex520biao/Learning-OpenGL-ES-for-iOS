//
//  OpenGLES_Ch7_1ViewController.m
//  OpenGLES_Ch7_1
//

#import "OpenGLES_Ch7_1ViewController.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModelManager.h"
#import "UtilityTextureInfo.h"
#import "AGLKContext.h"


@interface OpenGLES_Ch7_1ViewController ()
{
   NSMutableArray      *cars; // Cars to simulate
}

@property (strong, nonatomic) UtilityModelManager *modelManager;
@property (strong, nonatomic, strong) GLKBaseEffect *baseEffect;
@property (strong, nonatomic, strong) UtilityModel *carModel;
@property (strong, nonatomic, strong) UtilityModel *rinkModelFloor;
@property (strong, nonatomic, strong) UtilityModel *rinkModelWalls;
@property (nonatomic, assign, readwrite) 
   AGLKAxisAllignedBoundingBox rinkBoundingBox;

@end


@implementation OpenGLES_Ch7_1ViewController

@synthesize modelManager;
@synthesize baseEffect;
@synthesize carModel;
@synthesize rinkModelFloor;
@synthesize rinkModelWalls;
@synthesize rinkBoundingBox;


/////////////////////////////////////////////////////////////////
// Called when the view controller's view is loaded
// Perform initialization before the view is asked to draw
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   // Create an array to store cars
   cars = [[NSMutableArray alloc] init];
   
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
   self.baseEffect = [[GLKBaseEffect alloc] init];
   
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
   self.baseEffect.light0.position = GLKVector4Make(
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
      @"bumper" ofType:@"modelplist"];
   self.modelManager = 
      [[UtilityModelManager alloc] initWithModelPath:modelsPath];
   
   // Load models used to draw the scene
   self.carModel = [self.modelManager 
      modelNamed:@"bumperCar"];
   NSAssert(nil != self.carModel, 
      @"Failed to load car model");
   self.rinkModelFloor = [self.modelManager 
      modelNamed:@"bumperRinkFloor"];
   NSAssert(nil != self.rinkModelFloor, 
      @"Failed to load rink floor model");
   self.rinkModelWalls = [self.modelManager 
      modelNamed:@"bumperRinkWalls"];
   NSAssert(nil != self.rinkModelFloor, 
      @"Failed to load rink walls model");
   
   // Remember the rink bounding box for future collision 
   // detection with cars
   self.rinkBoundingBox = 
      self.rinkModelFloor.axisAlignedBoundingBox;
   NSAssert(0 < (self.rinkBoundingBox.max.x - 
      self.rinkBoundingBox.min.x) &&
      0 < (self.rinkBoundingBox.max.z - 
      self.rinkBoundingBox.min.z), 
      @"Rink has no area");
   
   // Create and add some cars to the simulation. The number of 
   // cars, colors and velocities are arbitrary
   [cars addObject:[[SceneCar alloc] 
      initWithModel:self.carModel
      position:GLKVector3Make(1.0, 0.0, 1.0)
      velocity:GLKVector3Make(1.5, 0.0, 1.5)
      color:GLKVector4Make(0.0, 0.5, 0.0, 1.0)]];
   
   [cars addObject:[[SceneCar alloc] 
      initWithModel:self.carModel
      position:GLKVector3Make(-1.0, 0.0, 1.0)
      velocity:GLKVector3Make(-1.5, 0.0, 1.5)
      color:GLKVector4Make(0.5, 0.5, 0.0, 1.0)]];
   
   [cars addObject:[[SceneCar alloc] 
      initWithModel:self.carModel
      position:GLKVector3Make(1.0, 0.0, -1.0)
      velocity:GLKVector3Make(-1.5, 0.0, -1.5)
      color:GLKVector4Make(0.5, 0.0, 0.0, 1.0)]];
   
   [cars addObject:[[SceneCar alloc] 
      initWithModel:self.carModel
      position:GLKVector3Make(2.0, 0.0, -2.0)
      velocity:GLKVector3Make(-1.5, 0.0, -0.5)
      color:GLKVector4Make(0.3, 0.0, 0.3, 1.0)]];
   
   // Set initial point of view to reasonable arbitrary values
   // These values make most of the simulated rink visible
   self.baseEffect.transform.modelviewMatrix =  
      GLKMatrix4MakeLookAt(
         10.5, 5.0, 0.0, // Eye position
         0.0, 0.5, 0.0,  // Look-at position
         0.0, 1.0, 0.0); // Up direction
         
   self.baseEffect.texture2d0.name = 
      self.modelManager.textureInfo.name;
   self.baseEffect.texture2d0.target = 
      self.modelManager.textureInfo.target;
}


/////////////////////////////////////////////////////////////////
// This method is called automatically at the update rate of the 
// receiver (default 30 Hz). This method is implemented to
// call each car's -updateWithCars: method to enable simulated 
// collision detection and car behavior.
- (void)update
{
   // Update the cars
   [cars makeObjectsPerformSelector:
      @selector(updateWithController:) withObject:self];
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
   
   // Calculate the aspect ratio for the scene and setup a 
   // perspective projection
   const GLfloat  aspectRatio = 
      (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
   
   self.baseEffect.transform.projectionMatrix = 
      GLKMatrix4MakePerspective(
         GLKMathDegreesToRadians(35.0f),// Standard field of view
         aspectRatio,
         4.0f,   // Don't make near plane too close
         20.0f); // Far arbitrarily far enough to contain scene
      
   [self.modelManager prepareToDraw];
   [self.baseEffect prepareToDraw];         

   // Draw the rink
   [self.rinkModelFloor draw];
   [self.rinkModelWalls draw];
   
   // Draw the cars
   [cars makeObjectsPerformSelector:
      @selector(drawWithBaseEffect:)
      withObject:self.baseEffect];
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
   cars = nil;
   carModel = nil;
   rinkModelFloor = nil;
   rinkModelWalls = nil;
}


/////////////////////////////////////////////////////////////////
// This method is called automatically and allows all standard 
// device orientations. 
- (BOOL)shouldAutorotateToInterfaceOrientation:
   (UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != 
       UIInterfaceOrientationPortraitUpsideDown &&
       interfaceOrientation != 
       UIInterfaceOrientationPortrait);
}


/////////////////////////////////////////////////////////////////
// Implements required accessor method for cars property
- (NSArray *)cars
{
   return cars;
}

@end
