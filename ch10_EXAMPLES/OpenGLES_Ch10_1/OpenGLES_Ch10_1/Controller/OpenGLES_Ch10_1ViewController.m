//
//  OpenGLES_Ch10_1ViewController.m
//  OpenGLES_Ch10_1
//

#import "OpenGLES_Ch10_1ViewController.h"
#import "OpenGLES_Ch10_1AppDelegate.h"
#import "TETerrain+viewAdditions.h"
#import "TEModelPlacement.h"
#import "UtilityModel.h"
#import "UtilityModelManager.h"
#import "UtilityTerrainEffect.h"
#import "UtilityModelEffect.h"
#import "UtilityPickTerrainEffect.h"
#import "UtilityCamera.h"

@class UtilityTextureInfo;


@interface OpenGLES_Ch10_1ViewController ()
{
   float angle;       // look direction angle about Y axis
   float targetAngle; // Target look direction angle about Y axis
}

@property (strong, nonatomic, readwrite) 
   UtilityTerrainEffect *terrainEffect;
@property (strong, nonatomic, readwrite) 
   UtilityPickTerrainEffect *pickTerrainEffect;
@property (strong, nonatomic, readwrite) 
   UtilityModelEffect *modelEffect;
@property (strong, nonatomic, readwrite) 
   UtilityCamera *camera;
@property (strong, nonatomic, readwrite) 
   NSArray *tiles;
@property (nonatomic, assign, readwrite) 
   GLfloat thirdPersonOffset;
@property (nonatomic, assign, readwrite) 
   GLfloat pitchOffset;
@property (nonatomic, assign, readwrite) 
   BOOL isAnimating;
@property (nonatomic, assign, readwrite) 
   GLKVector3 referencePosition;
@property (nonatomic, assign, readwrite) 
   GLKVector3 targetPosition;

@property (nonatomic, strong, readwrite) 
   UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong, readwrite) 
   UIPanGestureRecognizer *panRecognizer;

@property (assign, nonatomic) float filteredFPS;

@end


/////////////////////////////////////////////////////////////////
// Default frustum projection parameters
static const GLfloat OpenGLES_Ch10_1DefaultFieldOfView =
   (M_PI / 180.0f) * 45.0f;
static const GLfloat OpenGLES_Ch10_1DefaultNearLimit =
   0.5f;
static const GLfloat OpenGLES_Ch10_1DefaultFarLimit =
   5000.0f;

@implementation OpenGLES_Ch10_1ViewController

@synthesize dataSource;
@synthesize terrainEffect;
@synthesize pickTerrainEffect;
@synthesize modelEffect;
@synthesize camera;
@synthesize tiles;
@synthesize thirdPersonOffset;
@synthesize pitchOffset;
@synthesize isAnimating;
@synthesize referencePosition;
@synthesize targetPosition;
@synthesize tapRecognizer;
@synthesize panRecognizer;
@synthesize fpsField;
@synthesize filteredFPS;

#pragma mark - View lifecycle

/////////////////////////////////////////////////////////////////
//
- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/////////////////////////////////////////////////////////////////
//
- (void)awakeFromNib
{
   self.dataSource = (OpenGLES_Ch10_1AppDelegate *)
   [[UIApplication sharedApplication] delegate];
}


/////////////////////////////////////////////////////////////////
//
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   // Verify the type of view created automatically by the
   // Interface Builder storyboard
   GLKView *glView = (GLKView *)self.view;
   NSAssert([glView isKindOfClass:[GLKView class]],
            @"View controller's view is not a GLKView");
   
   // Use high resolution depth buffer
   glView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
   
   // Create an OpenGL ES 2.0 context and provide it to the
   // view
   glView.context = [[EAGLContext alloc] 
                     initWithAPI:kEAGLRenderingAPIOpenGLES2];
   
   // Make the new context current
   [EAGLContext setCurrentContext:glView.context];
   
   // Try to render as fast as possible
   self.preferredFramesPerSecond = 60;
   
   // init GL stuff here
   glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
   glEnable(GL_DEPTH_TEST);
   glEnable(GL_CULL_FACE);
   glEnable(GL_BLEND);
   glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
   
   // Camera used for placed blocks on game board
   self.camera = [[UtilityCamera alloc] init];
   self.camera.delegate = self;
   
   self.referencePosition = GLKVector3Make(
                                           400.0f, 0.0f, 400.0f);
   self.targetPosition = self.referencePosition;
   
   targetAngle = angle = 1.0f * M_PI / 4.0f; // Arbitrary angle
   [self.camera setPosition:self.referencePosition 
             lookAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f)];
   
   // Cache tiles in a property for future drawing
   self.tiles = [[self.dataSource terrain] tiles]; 
   
   // Create terrainEffect and configure properties that seldom
   // or never change 
   self.terrainEffect = 
      [[UtilityTerrainEffect alloc] 
      initWithTerrain:[self.dataSource terrain]];
   terrainEffect.globalAmbientLightColor = 
      GLKVector4Make(0.5, 0.5, 0.5, 1.0);
   TETerrain *terrain = [[self dataSource] terrain];
   
   self.terrainEffect.lightAndWeightsTextureInfo = 
      terrain.lightAndWeightsTextureInfo;
   self.terrainEffect.detailTextureInfo0 = 
      terrain.detailTextureInfo0;
   self.terrainEffect.detailTextureInfo1 = 
      terrain.detailTextureInfo1;
   self.terrainEffect.detailTextureInfo2 = 
      terrain.detailTextureInfo2;
   self.terrainEffect.detailTextureInfo3 = 
      terrain.detailTextureInfo3;
   
   // Create modelEffect and configure properties that seldom
   // or never change 
   self.modelEffect = [[UtilityModelEffect alloc] init];
   self.modelEffect.globalAmbientLightColor = 
      self.terrainEffect.globalAmbientLightColor;
   self.modelEffect.diffuseLightDirection = 
      GLKVector3Normalize(GLKVector3Make(
         terrain.lightDirectionX, 
         terrain.lightDirectionY, 
         terrain.lightDirectionZ));

   // Create pickTerrainEffect and configure properties that 
   // seldom or never change 
   self.pickTerrainEffect = 
      [[UtilityPickTerrainEffect alloc] 
       initWithTerrain:[self.dataSource terrain]];
   
   // Pre-warm GPU by downloading terrain data before it's needed
   [terrain prepareTerrainAttributes];

   // Pre-warm GPU by downloading model data before it's needed
   [[self.dataSource modelManager] prepareToDraw];   
         
#ifdef DEBUG
   {  // Report any errors 
      GLenum error = glGetError();
      if(GL_NO_ERROR != error)
      {
         NSLog(@"GL Error: 0x%x", error);
      }
   }
#endif
   
   {  // Create a tap recognizer and add it to the view.
      UITapGestureRecognizer *recognizer;
      recognizer = 
         [[UITapGestureRecognizer alloc] initWithTarget:self 
          action:@selector(handleTapFrom:)];
      [self.view addGestureRecognizer:recognizer];
      self.tapRecognizer = recognizer;
      recognizer.delegate = self;
   }
   
   
   {  // Create a pan recognizer and add it to the view.
      UIPanGestureRecognizer *recognizer;
      recognizer = 
         [[UIPanGestureRecognizer alloc] initWithTarget:self 
         action:@selector(handlePanFrom:)];
      [self.view addGestureRecognizer:recognizer];
      self.panRecognizer = recognizer;
      recognizer.delegate = self;
   }
}


/////////////////////////////////////////////////////////////////
//
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


#pragma mark - GLKViewDelegate

/////////////////////////////////////////////////////////////////
//
- (GLKMatrix3)matrixForScaleFactor:(float)aFactor;
{
   const float constWidthMeters = 
      self.dataSource.terrain.widthMeters;
   const float constLengthMeters = 
      self.dataSource.terrain.lengthMeters;
   const float constMetersPerUnit = 
      self.dataSource.terrain.metersPerUnit;
   
   NSAssert(0 < constWidthMeters, 
            @"Invalid terrain.widthMeters");
   NSAssert(0 < constLengthMeters, 
            @"Invalid terrain.lengthMeters");
   NSAssert(0 < constMetersPerUnit, 
            @"Invalid terrain.metersPerUnit");
   
   float widthScalefactor = 
      self.dataSource.terrain.detailTextureScale0 / 
      constMetersPerUnit;
   widthScalefactor = 
      MAX(widthScalefactor, 
          1.0f / constWidthMeters);
   float lengthScalefactor = 
      self.dataSource.terrain.detailTextureScale0 / 
      constMetersPerUnit;
   lengthScalefactor = 
      MAX(lengthScalefactor, 
      1.0f / constLengthMeters);
      
   return GLKMatrix3MakeScale(
      widthScalefactor, 
      1.0f, 
      lengthScalefactor);
}


/////////////////////////////////////////////////////////////////
//
- (void)updateDetailTextureMatrices
{
   self.terrainEffect.textureMatrix0 = 
      [self matrixForScaleFactor:
         self.dataSource.terrain.detailTextureScale0];
   self.terrainEffect.textureMatrix1 = 
      [self matrixForScaleFactor:
         self.dataSource.terrain.detailTextureScale1];
   self.terrainEffect.textureMatrix2 = 
      [self matrixForScaleFactor:
         self.dataSource.terrain.detailTextureScale2];
   self.terrainEffect.textureMatrix3 = 
      [self matrixForScaleFactor:
         self.dataSource.terrain.detailTextureScale3];
}


/////////////////////////////////////////////////////////////////
// 
- (void)update
{
   GLKVector3 direction = GLKVector3Subtract(
      self.targetPosition, self.referencePosition);
   direction.y = 0.0f;
   const float distance = GLKVector3Length(direction);
   
   if(0.01f >= distance && angle == targetAngle)
   { // No need to do anything
   }
   else 
   {
      if(1.0f >= distance)
      {
         self.referencePosition = self.targetPosition;
      }
      else
      {
         direction.x /= distance;
         direction.z /= distance;
         self.referencePosition = 
            GLKVector3Add(self.referencePosition, direction);
      }
      
      [self.camera moveBy:direction];
      self.referencePosition = [self.camera position];
      angle = targetAngle;
   }

   const NSTimeInterval elapsedTime = [self timeSinceLastUpdate];
   
   if(0.0 < elapsedTime)
   {
      const float unfilteredFPS = 1.0f / elapsedTime;
         
      // add part of the difference between current filtered FPS
      // and unfilteredFPS (simple low pass filter)
      self.filteredFPS += 0.2f * 
         (unfilteredFPS - self.filteredFPS);
   }
   
   fpsField.text = [NSString stringWithFormat:@"%03.1f FPS",
      self.filteredFPS];
}


/////////////////////////////////////////////////////////////////
// 
- (void)drawTerrainAndModels
{
   TETerrain *terrain = [[self dataSource] terrain];

   if(nil == self.tiles)
   {  // Cache tiles
      self.tiles = terrain.tiles;
   }
   
   // The terrain is opaque, so there is no need to blend.
   glDisable(GL_BLEND);

   [terrain drawTerrainWithinTiles:self.tiles 
      withCamera:self.camera
      terrainEffect:self.terrainEffect];

   // Assume subsequent rendering involves translucent objects.
   glEnable(GL_BLEND);
      
   // Configure modelEffect for texture and diffuse lighting
   self.modelEffect.texture2D = 
      [self.dataSource.modelManager textureInfo];
   self.modelEffect.projectionMatrix = 
      self.camera.projectionMatrix;
   self.modelEffect.modelviewMatrix = 
      self.camera.modelviewMatrix;
      
   [self.modelEffect prepareToDraw];
   [self.dataSource.modelManager prepareToDraw];   
      
   [terrain drawModelsWithinTiles:self.tiles
      withCamera:self.camera
      modelEffect:self.modelEffect
      modelManager:self.dataSource.modelManager];
}


/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
   const GLfloat    width = [view drawableWidth];
   const GLfloat    height = [view drawableHeight];
   
   NSParameterAssert(0 < height);
   const GLfloat aspectRatio = width / height;
   const GLfloat angleRad = OpenGLES_Ch10_1DefaultFieldOfView;
   
   // Configure projection and viewing/clipping volume
   [self.camera 
      configurePerspectiveFieldOfViewRad:angleRad
      aspectRatio:aspectRatio
      near:OpenGLES_Ch10_1DefaultNearLimit
      far:OpenGLES_Ch10_1DefaultFarLimit];
   
   [self updateDetailTextureMatrices];
   
   glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT); 
   
   [self drawTerrainAndModels];   
   
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


#pragma mark - Camera delegate

static const GLfloat TEHeadHeightMeters = (2.0f);

/////////////////////////////////////////////////////////////////
// Camera delegate method
- (BOOL)camera:(UtilityCamera *)aCamera
   willChangeEyePosition:(GLKVector3 *)eyePositionPtr
   lookAtPosition:(GLKVector3 *)lookAtPositionPtr
{
   TETerrain *terrain = [self.dataSource terrain];
   const float metersPerUnit = terrain.metersPerUnit;
   
   // Contrain referencePosition to terrain and keep it above
   // terrain height
   referencePosition.x = 
      MIN(MAX(2, referencePosition.x), terrain.widthMeters - 2);
   referencePosition.z = 
      MIN(MAX(2, referencePosition.z), terrain.lengthMeters - 2);
   
   const float heightAtReferencePosition = 
      [terrain calculatedHeightAtXPosMeters:referencePosition.x 
      zPosMeters:referencePosition.z
      surfaceNormal:NULL];
   
   referencePosition.y = 
      TEHeadHeightMeters + heightAtReferencePosition;
   
   // Ignore passed lookAt position and look in angle direction
   GLKVector3 lookAtPosition = 
      GLKVector3Make(
         referencePosition.x + cosf(angle) * metersPerUnit, 
         0.0f, 
         referencePosition.z + sinf(angle) * metersPerUnit);
   
   lookAtPosition.y = 
      [terrain calculatedHeightAtXPosMeters:lookAtPosition.x 
      zPosMeters:lookAtPosition.z
      surfaceNormal:NULL];     
   lookAtPosition.y = MAX(lookAtPosition.y, referencePosition.y);
   lookAtPosition.y += pitchOffset;
   
   *lookAtPositionPtr = lookAtPosition;
   *eyePositionPtr = self.referencePosition;     
   
   return YES;
}


#pragma mark - Responding to gestures

/////////////////////////////////////////////////////////////////
// 
- (TEPickTerrainInfo)pickTerrainAndModelsAtViewLocation:
   (CGPoint)aViewLocation
{
   GLKView *glView = (GLKView *)self.view;
   NSAssert([glView isKindOfClass:[GLKView class]],
            @"View controller's view is not a GLKView");

   // Make the view's context current
   [EAGLContext setCurrentContext:glView.context];
   
   TETerrain *terrain = [[self dataSource] terrain];

   if(nil == self.tiles)
   {  // Cache tiles
      self.tiles = terrain.tiles;
   }
   
   [terrain prepareToPickTerrain:self.tiles 
      withCamera:self.camera
      pickEffect:self.pickTerrainEffect];

   const GLfloat width = [glView drawableWidth];
   const GLfloat height = [glView drawableHeight];
   NSAssert(0 < width && 0 < height, @"Invalid drawble size");
   
   // Get info for picked location
   const GLKVector2 scaledProjectionPosition = {
      aViewLocation.x / width,
      aViewLocation.y / height
   };
   
   const TEPickTerrainInfo pickInfo = 
      [self.pickTerrainEffect terrainInfoForProjectionPosition:
      scaledProjectionPosition];
   
   // Restore OpenGL state that pickTerrainEffect changed   
   glBindFramebuffer(GL_FRAMEBUFFER, 0); // default frame buffer
   glViewport(0, 0, width, height); // full area of glView
   
#ifdef DEBUG
   {  // Report any errors 
      GLenum error = glGetError();
      if(GL_NO_ERROR != error)
      {
         NSLog(@"GL Error: 0x%x", error);
      }
   }
#endif

   //NSLog(@"{{%f, %f}, %d", 
   //   pickInfo.position.x, pickInfo.position.y,
   //   (NSInteger)pickInfo.modelIndex);
      
   return pickInfo;
}


/////////////////////////////////////////////////////////////////
// This method is part of the UIGestureRecognizerDelegate
// protocol. This implementation accepts tap and pan gestures
// and ignores prevents all others.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer 
       shouldReceiveTouch:(UITouch *)touch 
{
   BOOL     result = NO;
   
   if(gestureRecognizer == self.tapRecognizer || 
      gestureRecognizer == panRecognizer) 
   {
      result = YES;
   }
   
   return result;
}


/////////////////////////////////////////////////////////////////
// This method is called from a UIGestureRecognizer whenever
// the user taps a finger. This implementation interprets the
// tap location as the next target position for the camera.
- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer 
{ 
   CGPoint location = [recognizer locationInView:self.view];
   
   // Flip location for CG Y coordinates to GL coordinates 
   // conversion
   location.y = self.view.bounds.size.height - location.y;
   
   TEPickTerrainInfo pickInfo = 
      [self pickTerrainAndModelsAtViewLocation:location];
   
   const float constMetersPerUnit = 
   self.dataSource.terrain.metersPerUnit;
   
   if(0.0f < pickInfo.position.x && 0.0f < pickInfo.position.y)
   {
      self.targetPosition = 
         GLKVector3Make(
            pickInfo.position.x * constMetersPerUnit, 
            0.0f, 
            pickInfo.position.y * constMetersPerUnit);
   }
}


/////////////////////////////////////////////////////////////////
// This method is called from a UIGestureRecognizer whenever
// the user swipes a finger in a pan gesture. This implementation
// turns the cemera point of view about the Y axis (yaw) and 
// about the x axis (pitch).
- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer 
{
   
   if ([recognizer state] == UIGestureRecognizerStateBegan || 
       [recognizer state] == UIGestureRecognizerStateChanged) 
   {
      CGPoint velocity = [recognizer velocityInView:self.view];
      
      targetAngle -= 
         (velocity.x / self.view.bounds.size.width) * 0.1f; 
      self.pitchOffset -= 
         (velocity.y / self.view.bounds.size.height) * 0.5f; 
      self.pitchOffset = MAX(MIN(5.0f, self.pitchOffset), -5.0f);
   }
}

@end
