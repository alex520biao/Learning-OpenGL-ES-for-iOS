//
//  OpenGLES_Ch8_3ViewController.m
//  OpenGLES_Ch8_3
//

#import "OpenGLES_Ch8_3ViewController.h"
#import "AGLKContext.h"
#import "AGLKPointParticleEffect.h"


@interface OpenGLES_Ch8_3ViewController ()

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) AGLKPointParticleEffect *particleEffect;
@property (assign, nonatomic) NSTimeInterval autoSpawnDelta;
@property (assign, nonatomic) NSTimeInterval lastSpawnTime;
@property (assign, nonatomic) NSInteger currentEmitterIndex;
@property (strong, nonatomic) NSArray *emitterBlocks;
@property (strong, nonatomic) GLKTextureInfo 
   *ballParticleTexture;
@property (strong, nonatomic) GLKTextureInfo 
   *burstParticleTexture;
@property (strong, nonatomic) GLKTextureInfo 
   *smokeParticleTexture;

@end


@implementation OpenGLES_Ch8_3ViewController

@synthesize baseEffect = baseEffect_;
@synthesize particleEffect = particleEffect_;
@synthesize autoSpawnDelta = autoSpawnDelta_;
@synthesize lastSpawnTime = lastSpawnTime_;
@synthesize currentEmitterIndex = currentEmitterIndex_;
@synthesize emitterBlocks = emitterBlocks_;
@synthesize ballParticleTexture = ballParticleTexture_;
@synthesize burstParticleTexture = burstParticleTexture_;
@synthesize smokeParticleTexture = smokeParticleTexture_;

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
   
   // Load particle textures
   NSString *path = [[NSBundle bundleForClass:[self class]]
      pathForResource:@"ball" ofType:@"png"];
   NSAssert(nil != path, @"ball texture image not found");   
   NSError *error = nil;
   self.ballParticleTexture = [GLKTextureLoader 
      textureWithContentsOfFile:path 
      options:nil 
      error:&error];
   path = [[NSBundle bundleForClass:[self class]]
      pathForResource:@"burst" ofType:@"png"];
   NSAssert(nil != path, @"burst texture image not found");   
   self.burstParticleTexture = [GLKTextureLoader 
      textureWithContentsOfFile:path 
      options:nil 
      error:&error];
   path = [[NSBundle bundleForClass:[self class]]
      pathForResource:@"smoke" ofType:@"png"];
   NSAssert(nil != path, @"smoke texture image not found");   
   self.smokeParticleTexture = [GLKTextureLoader 
      textureWithContentsOfFile:path 
      options:nil 
      error:&error];
   
   // Create and configure particle effect
   self.particleEffect = [[AGLKPointParticleEffect alloc] init];
   self.particleEffect.texture2d0.name = 
      self.ballParticleTexture.name;
   self.particleEffect.texture2d0.target = 
      self.ballParticleTexture.target;

   // Set other persistent context state
   [(AGLKContext *)view.context setClearColor:
      GLKVector4Make(0.2f, 0.2f, 0.2f, 1.0f)];
   [(AGLKContext *)view.context enable:GL_DEPTH_TEST];
   [(AGLKContext *)view.context enable:GL_BLEND];
   [(AGLKContext *)view.context 
      setBlendSourceFunction:GL_SRC_ALPHA 
      destinationFunction:GL_ONE_MINUS_SRC_ALPHA];
   
   // Set number of seconds between automatic particle spawn 
   self.autoSpawnDelta = 0.0f;
   
   // Set initial emitter method
   self.currentEmitterIndex = 0;
   self.emitterBlocks = [NSArray arrayWithObjects:
      [^{  // Cannon ball
         self.autoSpawnDelta = 0.5f;

         // Turn on gravity
         self.particleEffect.gravity = AGLKDefaultGravity;
            
         float randomXVelocity = -0.5f + 1.0f * 
            (float)random() / (float)RAND_MAX;

         [self.particleEffect 
            addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.9f) 
            velocity:GLKVector3Make(randomXVelocity, 1.0f, -1.0f)
            force:GLKVector3Make(0.0f, 9.0f, 0.0f) 
            size:4.0f 
            lifeSpanSeconds:3.2f
            fadeDurationSeconds:0.5f];
      } copy],
      [^{  // Billow
         self.autoSpawnDelta = 0.05f;
         
         // Reverse gravity
         self.particleEffect.gravity = GLKVector3Make(
            0.0f, 0.5f, 0.0f);
            
         for(int i = 0; i < 20; i++)
         {
            float randomXVelocity = -0.1f + 0.2f * 
               (float)random() / (float)RAND_MAX;
            float randomZVelocity = 0.1f + 0.2f * 
               (float)random() / (float)RAND_MAX;
               
            [self.particleEffect 
               addParticleAtPosition:GLKVector3Make(0.0f, -0.5f, 0.0f) 
               velocity:GLKVector3Make(
                  randomXVelocity, 
                  0.0, 
                  randomZVelocity)
               force:GLKVector3Make(0.0f, 0.0f, 0.0f) 
               size:64.0f 
               lifeSpanSeconds:2.2f
               fadeDurationSeconds:3.0f];
         }
      } copy],
      [^{  // Pulse
         self.autoSpawnDelta = 0.5f;
         
         // Turn off gravity
         self.particleEffect.gravity = GLKVector3Make(
            0.0f, 0.0f, 0.0f);
            
         for(int i = 0; i < 100; i++)
         {
            float randomXVelocity = -0.5f + 1.0f * 
               (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f * 
               (float)random() / (float)RAND_MAX;
            float randomZVelocity = -0.5f + 1.0f * 
               (float)random() / (float)RAND_MAX;
               
            [self.particleEffect 
               addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f) 
               velocity:GLKVector3Make(
                  randomXVelocity, 
                  randomYVelocity, 
                  randomZVelocity)
               force:GLKVector3Make(0.0f, 0.0f, 0.0f) 
               size:4.0f 
               lifeSpanSeconds:3.2f
               fadeDurationSeconds:0.5f];
         }
      } copy],
      [^{  // Fire ring
         self.autoSpawnDelta = 3.2f;
         
         // Turn off gravity
         self.particleEffect.gravity = GLKVector3Make(
            0.0f, 0.0f, 0.0f);
            
         for(int i = 0; i < 100; i++)
         {
            float randomXVelocity = -0.5f + 1.0f * 
               (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f * 
               (float)random() / (float)RAND_MAX;
            GLKVector3 velocity = GLKVector3Normalize(
               GLKVector3Make(
                  randomXVelocity, 
                  randomYVelocity, 
                  0.0f));
                     
            [self.particleEffect 
               addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f)
               velocity:velocity
               force:GLKVector3MultiplyScalar(velocity, -1.5f) 
               size:4.0f 
               lifeSpanSeconds:3.2f
               fadeDurationSeconds:0.1f];
         }
      } copy],
      nil
   ];
}


/////////////////////////////////////////////////////////////////
// Called when the view controller's view has been unloaded
// Perform clean-up that is possible when you know the view 
// controller's view won't be asked to draw again soon.
- (void)viewDidUnload
{
   [super viewDidUnload];

   self.baseEffect = nil;
   self.particleEffect = nil;
}


/////////////////////////////////////////////////////////////////
// 
- (void)update
{  
   NSTimeInterval timeElapsed = self.timeSinceLastResume;
   
   self.particleEffect.elapsedSeconds = timeElapsed;
   
   if(self.autoSpawnDelta < (timeElapsed - self.lastSpawnTime))
   {
      self.lastSpawnTime = timeElapsed;
      
      // Call a block to emit particles
      void(^emitterBlock)() = 
         [self.emitterBlocks objectAtIndex:
            self.currentEmitterIndex];
      emitterBlock();
   }
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

   // Set initial point of view to reasonable arbitrary values
   // These values make most of the simulated rink visible
   self.baseEffect.transform.modelviewMatrix =  
      GLKMatrix4MakeLookAt(
         0.0, 0.0, 1.0,   // Eye position
         0.0, 0.0, 0.0,   // Look-at position
         0.0, 1.0, 0.0);  // Up direction
   
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
      -0.2f,  
      0.0f);// Directional light
   
   // Draw particles
   self.particleEffect.transform.projectionMatrix = 
      self.baseEffect.transform.projectionMatrix;
   self.particleEffect.transform.modelviewMatrix = 
      self.baseEffect.transform.modelviewMatrix;
   [self.particleEffect prepareToDraw];
   [self.particleEffect draw];
   
   [self.baseEffect prepareToDraw];   
   
   // ToDo: any other drawing here
   
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


/////////////////////////////////////////////////////////////////
// Action method called by user interface object 
- (IBAction)takeSelectedEmitterFrom:(UISegmentedControl *)sender;
{
   self.currentEmitterIndex = [sender selectedSegmentIndex];
}


/////////////////////////////////////////////////////////////////
// Action method called by user interface object 
- (IBAction)takeSelectedTextureFrom:(UISegmentedControl *)sender;
{
   NSUInteger index = [sender selectedSegmentIndex];
   
   switch(index)
   {
      case 0:
         self.particleEffect.texture2d0.name = 
            self.ballParticleTexture.name;
         self.particleEffect.texture2d0.target = 
            self.ballParticleTexture.target;
         break;
      case 1:
         self.particleEffect.texture2d0.name = 
            self.burstParticleTexture.name;
         self.particleEffect.texture2d0.target = 
            self.burstParticleTexture.target;
         break;
      case 2:
         self.particleEffect.texture2d0.name = 
            self.smokeParticleTexture.name;
         self.particleEffect.texture2d0.target = 
            self.smokeParticleTexture.target;
         break;
      default:
         self.particleEffect.texture2d0.name = 0;
         break;        
   }
}

@end
