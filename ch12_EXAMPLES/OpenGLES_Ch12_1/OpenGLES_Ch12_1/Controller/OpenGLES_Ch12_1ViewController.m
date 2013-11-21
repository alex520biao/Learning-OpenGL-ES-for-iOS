//
//  OpenGLES_Ch12_1ViewController.m
//  OpenGLES_Ch12_1
//

#import "OpenGLES_Ch12_1ViewController.h"
#import "OpenGLES_Ch12_1AppDelegate.h"
#import "AGLKFilters.h"
#import "TETerrain+viewAdditions.h"
#import "TECart+viewAdditions.h"
#import "TEModelPlacement.h"
#import "UtilityModel.h"
#import "UtilityModelManager.h"
#import "UtilityTerrainEffect.h"
#import "UtilityModelEffect.h"
#import "UtilityPickTerrainEffect.h"
#import "UtilityBillboardParticleEffect.h"
#import "UtilityCamera.h"
#import "UtilityBillboardParticleManager+viewAdditions.h"
#import <CoreMotion/CoreMotion.h>

@class UtilityTextureInfo;


@interface OpenGLES_Ch12_1ViewController ()

@property (strong, nonatomic, readwrite) 
   UtilityTerrainEffect *terrainEffect;
@property (strong, nonatomic, readwrite) 
   UtilityPickTerrainEffect *pickTerrainEffect;
@property (strong, nonatomic, readwrite) 
   UtilityModelEffect *modelEffect;
@property (strong, nonatomic, readwrite) 
   UtilityBillboardParticleEffect *particleEffect;
@property (strong, nonatomic, readwrite) 
   GLKSkyboxEffect *skyboxEffect;
@property (strong, nonatomic, readwrite) 
   UtilityCamera *camera;
@property (strong, nonatomic, readwrite) 
   NSArray *tiles;
@property (nonatomic, readonly) 
   TECart *playerCart;
@property (nonatomic, assign, readwrite) 
   GLKVector3 cameraPOVOffset;
@property (nonatomic, assign, readwrite) 
   GLfloat pitchAngleRadians;
@property (nonatomic, assign, readwrite) 
   GLfloat yawAngleRadians;
@property (nonatomic, assign, readwrite) 
   GLfloat rollAngleRadians;
@property (nonatomic, assign, readwrite) 
   GLKVector3 accelerationVector;
@property (nonatomic, strong, readwrite)
   UtilityBillboardParticleManager *particleManager;
@property (strong, nonatomic) 
   GLKTextureInfo *particleTexture;
@property (assign, nonatomic)
   GLfloat simplificationDistanceTiles;
@property (assign, nonatomic) 
   GLfloat filteredFPS;
@property (assign, nonatomic) 
   BOOL hasUpdated;
   
// Outlets and user event sources
@property (nonatomic, strong, readwrite) 
   CMMotionManager *motionManager;
@property (nonatomic, strong, readwrite) 
   UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong, readwrite) 
   UIPanGestureRecognizer *panRecognizer;


@end


/////////////////////////////////////////////////////////////////
// Default frustum projection parameters
static const GLfloat OpenGLES_Ch12_1DefaultFieldOfView =
   (M_PI / 180.0f) * 55.0f;
static const GLfloat OpenGLES_Ch12_1DefaultNearLimit =
   0.5f;
static const GLfloat OpenGLES_Ch12_1DefaultFarLimit =
   14000.0f;

@implementation OpenGLES_Ch12_1ViewController

@synthesize dataSource = dataSource_;
@synthesize terrainEffect = terrainEffect_;
@synthesize pickTerrainEffect = pickTerrainEffect_;
@synthesize modelEffect = modelEffect_;
@synthesize particleEffect = particleEffect_;
@synthesize skyboxEffect = skyboxEffect_;
@synthesize camera = camera_;
@synthesize tiles = tiles_;
@synthesize cameraPOVOffset = cameraPOVOffset_;
@synthesize pitchAngleRadians = pitchAngleRadians_;
@synthesize yawAngleRadians = yawAngleRadians_;
@synthesize rollAngleRadians = rollAngleRadians_;
@synthesize accelerationVector = accelerationVector_;
@synthesize particleManager = particleManager_;
@synthesize particleTexture = particleTexture_;
@synthesize simplificationDistanceTiles = 
   simplificationDistanceTiles_;
@synthesize hasUpdated = hasUpdated_;
@synthesize filteredFPS = filteredFPS_;

// Outlets and user event sources
@synthesize motionManager = motionManager_;
@synthesize tapRecognizer = tapRecognizer_;
@synthesize panRecognizer = panRecognizer_;
@synthesize fpsField = fpsField_;

#pragma mark - Load time configuration

/////////////////////////////////////////////////////////////////
// Configure the GLKView controlled by the receiver and set the 
// initial state of the OpenGL ES 2.0 context.
- (void)configureControlledViewAndContext
{
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
   
   // init seldom changing context state 
   glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
   glEnable(GL_DEPTH_TEST);
   glEnable(GL_CULL_FACE);
   glEnable(GL_BLEND);
   glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}


/////////////////////////////////////////////////////////////////
// Returns a matrix suitable for scaling a terrain texture.
- (GLKMatrix3)matrixForScaleFactor:(GLfloat)aFactor;
{
   const GLfloat constWidthMeters = 
      self.terrain.widthMeters;
   const GLfloat constLengthMeters = 
      self.terrain.lengthMeters;
   const GLfloat constMetersPerUnit = 
      self.terrain.metersPerUnit;
   
   NSAssert(0 < constWidthMeters, 
            @"Invalid terrain.widthMeters");
   NSAssert(0 < constLengthMeters, 
            @"Invalid terrain.lengthMeters");
   NSAssert(0 < constMetersPerUnit, 
            @"Invalid terrain.metersPerUnit");
   
   GLfloat widthScalefactor = 
      self.terrain.detailTextureScale0 / 
      constMetersPerUnit;
   widthScalefactor = 
      MAX(widthScalefactor, 
          1.0f / constWidthMeters);
   GLfloat lengthScalefactor = 
      self.terrain.detailTextureScale0 / 
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
// Updates the receiver's terrain effect to use terrain detail
// textures stored by the receiver's terrain object.
- (void)configureDetailTextureMatrices
{
   self.terrainEffect.textureMatrix0 = 
      [self matrixForScaleFactor:
         self.terrain.detailTextureScale0];
   self.terrainEffect.textureMatrix1 = 
      [self matrixForScaleFactor:
         self.terrain.detailTextureScale1];
   self.terrainEffect.textureMatrix2 = 
      [self matrixForScaleFactor:
         self.terrain.detailTextureScale2];
   self.terrainEffect.textureMatrix3 = 
      [self matrixForScaleFactor:
         self.terrain.detailTextureScale3];
}


/////////////////////////////////////////////////////////////////
// Create and configure the receiver's terrain effect.
- (void)configureTerrainEffect
{
   TETerrain *terrain = self.terrain;
   NSAssert(nil != terrain, @"Invalid terrain");
   
   // Cache tiles in a property for future drawing
   self.tiles = [terrain tiles]; 

   // Create terrainEffect and configure properties that seldom
   // or never change 
   self.terrainEffect = 
      [[UtilityTerrainEffect alloc] 
      initWithTerrain:self.terrain];
   self.terrainEffect.globalAmbientLightColor = 
      GLKVector4Make(0.5, 0.5, 0.5, 1.0);
   
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
   
   [self configureDetailTextureMatrices];
}


/////////////////////////////////////////////////////////////////
// Create and configure the receiver's model effect.
- (void)configureModelEffect
{
   TETerrain *terrain = self.terrain;
   NSAssert(nil != terrain, @"Invalid terrain");
   
   // Create modelEffect and configure properties that seldom
   // or never change 
   self.modelEffect = [[UtilityModelEffect alloc] init];
   self.modelEffect.diffuseLightDirection = 
      GLKVector3Normalize(GLKVector3Make(
         terrain.lightDirectionX, 
         terrain.lightDirectionY, 
         terrain.lightDirectionZ));
   self.modelEffect.globalAmbientLightColor = 
      self.terrainEffect.globalAmbientLightColor;
   self.modelEffect.diffuseLightColor = 
      GLKVector4Make(0.7, 0.7, 0.7, 1.0);         
}


/////////////////////////////////////////////////////////////////
// Create and configure the receiver's pick effect.
- (void)configurePickEffect
{
   // Create pickTerrainEffect and configure properties that 
   // seldom or never change 
   self.pickTerrainEffect = 
      [[UtilityPickTerrainEffect alloc] 
       initWithTerrain:[self.dataSource terrain]];
}


/////////////////////////////////////////////////////////////////
// Create and configure the receiver's skybox.
- (void)configureSkybox
{
   // Create and configure skybox
   TETerrain *terrain = self.terrain;
   NSAssert(nil != terrain, @"Invalid terrain");
   
   // Load skybox cubeMap texture
   NSString *path = [[NSBundle bundleForClass:[self class]]
      pathForResource:@"skybox004" ofType:@"png"];
   NSAssert(nil != path, 
      @"Path to skybox image not found");   
   NSError *error = nil;
   GLKTextureInfo *skyboxTextureInfo = [GLKTextureLoader 
      cubeMapWithContentsOfFile:path 
      options:nil 
      error:&error];
   NSAssert(nil != skyboxTextureInfo, 
      @"Invalid skyboxTextureInfo: %@", error);   

   self.skyboxEffect = [[GLKSkyboxEffect alloc] init];
   self.skyboxEffect.textureCubeMap.name = 
      skyboxTextureInfo.name;
   self.skyboxEffect.textureCubeMap.target = 
      skyboxTextureInfo.target;
   
   GLfloat maxDimension = 3.0f *
      MAX(terrain.lengthMeters, terrain.widthMeters);
   self.skyboxEffect.xSize = maxDimension;
   self.skyboxEffect.ySize = maxDimension;
   self.skyboxEffect.zSize = maxDimension;   
   self.skyboxEffect.center = GLKVector3Make(
      0.5f * terrain.widthMeters, 
      terrain.heightMeters, 
      0.5f * terrain.lengthMeters);
}


/////////////////////////////////////////////////////////////////
// Create and configure the receiver's particle manager.
- (void)configureParticleManagerAndEffect
{
   // Load particle texture
   NSString *particleImagePath = 
      [[NSBundle bundleForClass:[self class]]
      pathForResource:@"texture0" ofType:@"png"];
   NSAssert(nil != particleImagePath, 
      @"Path to particle image not found");   
   NSError *error = nil;
   self.particleTexture = [GLKTextureLoader 
      textureWithContentsOfFile:particleImagePath 
      options:[NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:YES], GLKTextureLoaderGenerateMipmaps,
         nil] 
      error:&error];
   NSAssert(nil != self.particleTexture, 
      @"Failed loading texture0");
   
   self.particleEffect =
      [[UtilityBillboardParticleEffect alloc] init];
   self.particleManager = 
      [[UtilityBillboardParticleManager alloc] init];
}


/////////////////////////////////////////////////////////////////
// Create and configure gesture recognizers and a motion manager
// to receive inputs from user ouches and device motion.
- (void)configureMotionManagerAndGestureRecognizers
{
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
   
   self.motionManager = [[CMMotionManager alloc] init];
   [self.motionManager startDeviceMotionUpdates];
}


#pragma mark - Device orientation

/////////////////////////////////////////////////////////////////
// Prepare the receiver's camera for scene rendering. Call this
// method anytime the receiver's device orientation changes.
- (void)prepareCameraForDeviceOrientation
{
   if(self.hasUpdated)
   {
      GLKView *view = (GLKView *)self.view;
         
      const GLfloat    width = [view drawableWidth];
      const GLfloat    height = [view drawableHeight];
      
      NSParameterAssert(0 < height);
      const GLfloat aspectRatio = width / height;
      const GLfloat angleRad = OpenGLES_Ch12_1DefaultFieldOfView;
      
      // Configure projection and viewing/clipping volume
      [self.camera 
         configurePerspectiveFieldOfViewRad:angleRad
         aspectRatio:aspectRatio
         near:OpenGLES_Ch12_1DefaultNearLimit
         far:OpenGLES_Ch12_1DefaultFarLimit];
   }
}


/////////////////////////////////////////////////////////////////
// This method is called automatically and allows only landscape 
// device orientations. 
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
   BOOL result = NO;
   
   if ([[UIDevice currentDevice] userInterfaceIdiom] == 
       UIUserInterfaceIdiomPhone) 
   {
      result = (interfaceOrientation != 
              UIInterfaceOrientationPortraitUpsideDown &&
              interfaceOrientation != 
              UIInterfaceOrientationPortrait);
   } 
   else 
   {
      result = (interfaceOrientation != 
              UIInterfaceOrientationPortraitUpsideDown &&
              interfaceOrientation != 
              UIInterfaceOrientationPortrait);
   }
   
   if(YES == result)
   {
      [self prepareCameraForDeviceOrientation];   
   }
   
   return result;
}


#pragma mark - View lifecycle

/////////////////////////////////////////////////////////////////
// This method is called automatically after all objects and 
// connections loaded from the user interface "storyboard" have 
// been reconstituted.
- (void)awakeFromNib
{
}


/////////////////////////////////////////////////////////////////
// Called when the view controller's view is loaded
// Perform initialization before the view is asked to draw
- (void)viewDidLoad
{
   [super viewDidLoad];

   self.hasUpdated = NO;
   
   // set the receiver's dataSource property to the shared 
   // UIApplication instance
   self.dataSource = (OpenGLES_Ch12_1AppDelegate *)
      [[UIApplication sharedApplication] delegate];

   // Try to render at a stable 30Hz
   self.preferredFramesPerSecond = 30;
   
   // Create and configure camera 
   self.camera = [[UtilityCamera alloc] init];
   self.camera.delegate = self;
   [self prepareCameraForDeviceOrientation];
   
   [self configureControlledViewAndContext];
   [self configureTerrainEffect];
   [self configureModelEffect];
   [self configurePickEffect];
   [self configureSkybox];
   [self configureParticleManagerAndEffect];
   
   // Pre-warm GPU by downloading terrain data before it's needed
   [self.terrain prepareTerrainAttributes];

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
   
   [self configureMotionManagerAndGestureRecognizers];
}


/////////////////////////////////////////////////////////////////
// Called when the view controller's view has been unloaded
// Perform clean-up that is possible when you know the view 
// controller's view won't be asked to draw again soon.
- (void)viewDidUnload
{
   [super viewDidUnload];

   self.camera = nil;
   self.tiles = nil;
   self.terrainEffect = nil;
   self.modelEffect = nil;
   self.pickTerrainEffect = nil;
   self.particleEffect = nil;
   self.skyboxEffect = nil;
   [self.motionManager stopDeviceMotionUpdates];
   [self.motionManager stopAccelerometerUpdates];
   self.motionManager = nil;
   self.particleManager = nil;
}


#pragma mark - Accessors

/////////////////////////////////////////////////////////////////
// Return's the receiver's datasource's terrain property.
- (TETerrain *)terrain;
{
   return self.dataSource.terrain;
}


/////////////////////////////////////////////////////////////////
// Returns the receiver's player's cart.
- (TECart *)playerCart
{
   TECart *result = nil;

   if(0 < self.dataSource.carts.count)
   {
      result = [self.dataSource.carts objectAtIndex:0];
   }
   
   return result;
}


#pragma mark - GLKViewDelegate Updating

/////////////////////////////////////////////////////////////////
// Factor used to dampen motion inputs controlling cart yaw
static const GLfloat TEDeviceRotationFactor = (0.03f);

/////////////////////////////////////////////////////////////////
// This method updates the player's cart orientation in response
// to device motion. Turning the device turns the player's cart.
- (void)updatePlayerCartForDeviceMotion
{
   TECart *playerCart = [self playerCart];
   
   // Update cart direction based on device motion inputs
   if(self.motionManager.isDeviceMotionActive)
   {
      self.rollAngleRadians = TEDeviceRotationFactor *
         self.motionManager.deviceMotion.attitude.pitch;
   }
   else
   {  // Use device accelerometer when other sources unavailable
      if(!self.motionManager.isAccelerometerActive)
      {
         [self.motionManager startAccelerometerUpdates];
      }
      
      self.rollAngleRadians = -TEDeviceRotationFactor *
         self.motionManager.accelerometerData.acceleration.y;
   }
   
   [playerCart turnDeltaRadians:self.rollAngleRadians];
}


/////////////////////////////////////////////////////////////////
// This method updates all of the receiver's carts allowing them
// to update their positions and orientations as well as emit 
// particles.
- (void)updateCarts
{
   // Give carts a chance to update positions, velocities,
   // orientations, etc.
   for(TECart *cart in self.dataSource.carts)
   {
      [cart updateWithController:self];
   }
   
   // React to any collisions between carts
   for(TECart *cart in self.dataSource.carts)
   {
      [cart bounceOffCarts:self.dataSource.carts
         elapsedTime:self.timeSinceLastUpdate];
   }
}


/////////////////////////////////////////////////////////////////
// Update the receiver's camera position and orientation to match
// the player's cart position and orientation with offset to
// control first person vs. third person point of view.
- (void)updateCamera
{
   TECart *playerCart = [self playerCart];
   
   // Make camera match cart position and orientation
   GLKVector3 newCameraPosition = GLKVector3Add(
      playerCart.position, 
      GLKVector3MultiplyScalar(
         playerCart.upUnitVector, 1.2f)
      );
   newCameraPosition = GLKVector3Add(
      newCameraPosition, 
      GLKVector3MultiplyScalar(
         playerCart.forwardUnitVector, -0.3f)
      );
   GLKVector3 newCameraLookAtPosition = GLKVector3Add(
      newCameraPosition, 
      playerCart.forwardUnitVector);
   
   // Apply third person POV to camera position
   newCameraPosition = GLKVector3Add(
      newCameraPosition, 
      GLKVector3MultiplyScalar(
         playerCart.rightUnitVector, self.cameraPOVOffset.x)
      );
   newCameraPosition = GLKVector3Add(
      newCameraPosition, 
      GLKVector3MultiplyScalar(
         playerCart.upUnitVector, self.cameraPOVOffset.y)
      );
   newCameraPosition = GLKVector3Add(
      newCameraPosition, 
      GLKVector3MultiplyScalar(
         playerCart.forwardUnitVector, self.cameraPOVOffset.z)
      );
      
   [self.camera setPosition:newCameraPosition 
      lookAtPosition:newCameraLookAtPosition];
      
   // Apply user input to camera orientation (look around)
   [self.camera rotateAngleRadiansAboutX:self.pitchAngleRadians];
   [self.camera rotateAngleRadiansAboutY:self.yawAngleRadians];
}


/////////////////////////////////////////////////////////////////
// Update the Frames Per Second field in the user interface.
- (void)updateFPSField
{
   const NSTimeInterval elapsedTime = [self timeSinceLastUpdate];
   
   if(0.0 < elapsedTime)
   {
      const GLfloat unfilteredFPS = 1.0f / elapsedTime;
         
      // add part of the difference between current filtered FPS
      // and unfilteredFPS (simple low pass filter)
      self.filteredFPS += 0.2f * 
         (unfilteredFPS - self.filteredFPS);
   }
   
   self.fpsField.text = [NSString stringWithFormat:@"%03.1f FPS",
      self.filteredFPS];
}


/////////////////////////////////////////////////////////////////
// This constant specifies how distant a tile needs to be from
// viewer for the tile to be drawn in a simplified form. The
// distance is measured in tiles, so a distance of 4
// means that a tile five tiles away from the viewer will be
// drawn simplified.
static const NSInteger 
OpenGLES_Ch12_1DefaultSimplifaicationDistanceInTiles = 4;

/////////////////////////////////////////////////////////////////
// This method is called automatically at the update rate of the 
// receiver (default 30 Hz). This method is implemented to 
// update the displayed FPS field, the carts, the camera, and 
// any particles.
- (void)update
{
   if(!self.hasUpdated)
   {
      self.hasUpdated = YES;
      
      // Update device orientation if there hasn't been an update
      // since view was loaded.
      [self prepareCameraForDeviceOrientation];
      
      // Start assuming reasonable update rate
      self.simplificationDistanceTiles = 
         OpenGLES_Ch12_1DefaultSimplifaicationDistanceInTiles;
   }
   
   [self updateFPSField];
   [self updatePlayerCartForDeviceMotion];
   [self updateCarts];
   [self updateCamera];
   
   const GLfloat elapsedTime = [self timeSinceLastUpdate];
   
   if((1.0f / 20.0f) < elapsedTime)
   {  // simplify to improve performance
      self.simplificationDistanceTiles = 
         OpenGLES_Ch12_1DefaultSimplifaicationDistanceInTiles / 2;
   }
                     
   // Update the particle manager's existing particles 
   [self.particleManager updateWithElapsedTime:elapsedTime
      frustum:self.camera.frustumForCulling];
}


#pragma mark - GLKViewDelegate Drawing

/////////////////////////////////////////////////////////////////
// This method draws the skybox followed by the visible terrain
// followed by models within the visible terrain. That order 
// potentially minimizes the amount of overdraw. i.e. the number
// of times color render buffer pixels are written per display
// update.
- (void)drawTerrainSkyAndModels
{
   TETerrain *terrain = [[self dataSource] terrain];

   if(nil == self.tiles)
   {  // Cache tiles
      self.tiles = terrain.tiles;
   }

   NSMutableArray *fullDetailTiles = [NSMutableArray array];
   NSMutableArray *simplifiedTiles = [NSMutableArray array];

   // Identify the tiles to be drawn (some may be culled)
   [terrain identifyTilesToDraw:self.tiles
      withCamera:self.camera
      fullDetail:fullDetailTiles
      simplified:simplifiedTiles
      simplificationDistanceTiles:
         self.simplificationDistanceTiles];
   
   // The terrain and skybox are both opaque, so there is no 
   // need to blend.
   glDisable(GL_BLEND);

   [terrain drawTerrainWithinFullDetailTiles:fullDetailTiles 
      simplifiedTiles:simplifiedTiles
      withCamera:self.camera
      terrainEffect:self.terrainEffect];

   // Draw skybox centered at camera position with current camera
   // transforms
   {
      self.skyboxEffect.transform.projectionMatrix = 
         self.camera.projectionMatrix;
      self.skyboxEffect.transform.modelviewMatrix = 
         GLKMatrix4Translate(self.camera.modelviewMatrix, 
            -self.camera.position.x, 
            -self.camera.position.y, 
            -self.camera.position.z); 
         
      [self.skyboxEffect prepareToDraw];
      [self.skyboxEffect draw];
      glBindVertexArrayOES(0);
   }
   
   // Assume subsequent rendering involves translucent objects.
   glEnable(GL_BLEND);

   // Draw models within full detail tiles
   {
      // Configure modelEffect for texture and diffuse lighting
      self.modelEffect.texture2D = 
         [self.dataSource.modelManager textureInfo];
      self.modelEffect.projectionMatrix = 
         self.camera.projectionMatrix;
      self.modelEffect.modelviewMatrix = 
         self.camera.modelviewMatrix;
         
      [self.modelEffect prepareToDraw];
      [self.dataSource.modelManager prepareToDraw];   
      
      [terrain drawModelsWithinTiles:fullDetailTiles
         withCamera:self.camera
         modelEffect:self.modelEffect
         modelManager:self.dataSource.modelManager];
   }
}


/////////////////////////////////////////////////////////////////
// This method prepares the relevant effects and then draws the 
// receiver's carts.
- (void)drawCarts
{
   [self.dataSource.playerModelManager prepareToDraw];   

   // Configure modelEffect for texture and diffuse lighting
   self.modelEffect.texture2D = 
      [self.dataSource.playerModelManager textureInfo];
   self.modelEffect.projectionMatrix = 
      self.camera.projectionMatrix;
   [self.modelEffect prepareToDraw];
      
   // Draw the carts  
   for(TECart *cart in self.dataSource.carts)
   {
      self.modelEffect.modelviewMatrix = 
         self.camera.modelviewMatrix;
      [cart drawWithEffect:self.modelEffect];
   }
}


/////////////////////////////////////////////////////////////////
// Configure the receiver's particle manager to match current
// camera orientation and then draw any active particles.
- (void)drawBillboardParticles
{
   self.particleEffect.texture2D = self.particleTexture;
   self.particleEffect.projectionMatrix = 
      self.camera.projectionMatrix;
   self.particleEffect.modelviewMatrix = 
      self.camera.modelviewMatrix;
   
   [self.particleEffect prepareToDraw];      
   [self.particleManager drawWithCamera:self.camera];
}


/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
   if(self.hasUpdated)
   {
      glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT); 

      [self drawCarts];
      [self drawTerrainSkyAndModels];   
      [self drawBillboardParticles];
      
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
}


#pragma mark - Camera delegate

/////////////////////////////////////////////////////////////////
// Camera delegate method
- (BOOL)camera:(UtilityCamera *)aCamera
   willChangeEyePosition:(GLKVector3 *)eyePositionPtr
   lookAtPosition:(GLKVector3 *)lookAtPositionPtr;
{
   return YES;
}


#pragma mark - Responding to gestures and actions

/////////////////////////////////////////////////////////////////
// This method is part of the UIGestureRecognizerDelegate
// protocol. This implementation accepts tap and pan gestures
// and ignores prevents all others.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer 
       shouldReceiveTouch:(UITouch *)touch 
{
   BOOL     result = NO;
   
   if(gestureRecognizer == self.tapRecognizer || 
      gestureRecognizer == self.panRecognizer) 
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
   
   // Do something with touch / picking
}


/////////////////////////////////////////////////////////////////
// This method is called from a UIGestureRecognizer whenever
// the user swipes a finger in a pan gesture. This implementation
// turns the camera point of view about the Y axis (yaw) and 
// about the x axis (pitch).
- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer 
{
   
   if ([recognizer state] == UIGestureRecognizerStateBegan || 
       [recognizer state] == UIGestureRecognizerStateChanged) 
   {
      CGPoint velocity = [recognizer velocityInView:self.view];
      
      self.yawAngleRadians -= 
         (velocity.x / self.view.bounds.size.width) * 0.1f;
      self.yawAngleRadians = MAX(MIN(self.yawAngleRadians,
         M_PI/4.0f), -M_PI/4.0f);
      self.pitchAngleRadians += 
         (velocity.y / self.view.bounds.size.height) * 0.1f; 
      self.pitchAngleRadians = MAX(MIN(self.pitchAngleRadians,
         M_PI/8.0f), -M_PI/5.0f);
   }
}


/////////////////////////////////////////////////////////////////
// Start "boost" acceleration of player's cart. 
- (IBAction)startBoosting:(id)sender;
{
   [self.dataSource.playerCart startBoosting];
}


/////////////////////////////////////////////////////////////////
// Stop "boost" acceleration of player's cart. 
- (IBAction)stopBoosting:(id)sender;
{
   [self.dataSource.playerCart stopBoosting];
}


/////////////////////////////////////////////////////////////////
// The camera offset from the cart position used to create third
// person point of view.
static const GLKVector3 TEThirdPersonOffset = {0.0f, 3.0f, -5.0f};
   
/////////////////////////////////////////////////////////////////
// The camera offset from the cart position used to create third
// person point of view.
static const GLKVector3 TEFirstPersonOffset = {0.0f, 0.0f, 0.0f};
   
   
/////////////////////////////////////////////////////////////////
// Modify the third person offset to switch camera positions 
// between inside the player's cart and GLfloating above vs. behind
// the player's cart.
- (IBAction)toggleFirstPersonPOV:(id)sender;
{
   if(1.0f >= self.cameraPOVOffset.y)
   {
      self.cameraPOVOffset = TEThirdPersonOffset;
      self.pitchAngleRadians = M_PI/6.0f;
   }
   else
   {
      self.cameraPOVOffset = TEFirstPersonOffset;
      self.pitchAngleRadians = 0.0f;
   } 
}

@end
