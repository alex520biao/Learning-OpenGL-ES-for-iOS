//
//  TEView.m
//  TerrainViewer
//

#import "TEView.h"
#import "TETerrain+modelAdditions.h"
#import "TETerrainEffect.h"
#import "TETerrainEffect.h"
#import "TEPickTerrainEffect.h"
#import "TEModel.h"
#import "TEModelManager.h"
#import "TEModelPlacement.h"
#import "TEModelEffect.h"
#import "TEDocument.h"
#import "UtilityOpenGLCamera.h"
#import "UtilityVector.h"


@interface TEView ()
{
   float angle;
}

@property (strong, nonatomic, readwrite) TETerrainEffect *terrainEffect;
@property (strong, nonatomic, readwrite) TEPickTerrainEffect *pickTerrainEffect;
@property (strong, nonatomic, readwrite) TEModelEffect *modelEffect;
@property (strong, nonatomic, readwrite) UtilityOpenGLCamera *camera;
@property (strong, nonatomic, readwrite) NSArray *tiles;
@property (nonatomic, assign, readwrite) UtilityVector3 referencePosition;
@property (nonatomic, assign, readwrite) GLfloat thirdPersonOffset;
@property (nonatomic, assign, readwrite) GLfloat pitchOffset;
@property (nonatomic, assign, readwrite) BOOL isAnimating;

@end


@implementation TEView

@synthesize dataSource;
@synthesize terrainEffect;
@synthesize pickTerrainEffect;
@synthesize modelEffect;
@synthesize camera;
@synthesize tiles;
@synthesize referencePosition;
@synthesize thirdPersonOffset;
@synthesize pitchOffset;
@synthesize isAnimating;
@synthesize editingLightAndWeightsTextureInfo;
@synthesize modelPlacementArrayController;
@synthesize shouldShowTexture;
@synthesize shouldShowGrid;


#pragma mark - Init & configuration

/////////////////////////////////////////////////////////////////
//
+ (NSOpenGLPixelFormat*)basicPixelFormat
{
   NSOpenGLPixelFormatAttribute attributes [] = {
      NSOpenGLPFAWindow,
      NSOpenGLPFADoubleBuffer,    // double buffered
      NSOpenGLPFADepthSize, 
      (NSOpenGLPixelFormatAttribute)16, // 16 bit depth buffer
      (NSOpenGLPixelFormatAttribute)nil
   };
   
   return [[[NSOpenGLPixelFormat alloc] 
            initWithAttributes:attributes] autorelease];
}


/////////////////////////////////////////////////////////////////
//
-(id)initWithFrame:(NSRect)frameRect
{
   NSOpenGLPixelFormat * pf = [[self class] basicPixelFormat];
   
   self = [super initWithFrame: frameRect pixelFormat: pf];
   self.shouldShowTexture = YES;
   self.shouldShowGrid = NO;
   
   
   return self;
}


/////////////////////////////////////////////////////////////////
//
- (void)dealloc
{
   self.terrainEffect = nil;
   self.pickTerrainEffect = nil;
   self.camera = nil;
   self.dataSource = nil;
   
   [super dealloc];
}


/////////////////////////////////////////////////////////////////
//
- (BOOL)acceptsFirstResponder
{
   return YES;
}


/////////////////////////////////////////////////////////////////
//
- (BOOL)becomeFirstResponder
{
   return  YES;
}


/////////////////////////////////////////////////////////////////
//
- (BOOL)resignFirstResponder
{
   return YES;
}


/////////////////////////////////////////////////////////////////
//
- (void)initGL
{
   if(nil == self.camera)
   {
      // Camera used for placed blocks on game board
      self.camera = [[[UtilityOpenGLCamera alloc] init] autorelease];
      self.camera.delegate = self;
      self.referencePosition = UtilityVector3Make(
                                                  0.0f, 0.0f, 0.0f);
      
      [self.camera setLookAtPosition:
       UtilityVector3Make(
                          0.0f, 0.0f, -1.0f)];
      [self.camera setPosition:self.referencePosition];
      glEnable(GL_BLEND);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
   }
}


/////////////////////////////////////////////////////////////////
//
- (void)awakeFromNib
{
   NSAssert(nil != [self.dataSource terrain],
            @"dataSource or terrain not available");
   
   NSUndoManager *undoManager = [self undoManager];
   [[NSNotificationCenter defaultCenter]
    postNotificationName:NSUndoManagerCheckpointNotification
    object:undoManager];
   [undoManager disableUndoRegistration];
   
	// Make this openGL context current to the thread
	// (i.e. all openGL on this thread calls will go to this context)
	[[self openGLContext] makeCurrentContext];
   
   [self initGL];
   
   // Prime terrain for drawing so that all properties have 
   // reasonable default values before undo is re-enabled
   [[self.dataSource terrain] prepareToDraw];
   
   // Cache tiles in a property for future drawing
   self.tiles = [[self.dataSource terrain] tiles];   
   
   self.terrainEffect = 
   [[[TETerrainEffect alloc] 
     initWithTerrain:[self.dataSource terrain]] autorelease];
   terrainEffect.globalAmbientLightColor = 
   UtilityVector4Make(0.5, 0.5, 0.5, 1.0);
   
   // Configure a default tool texture 
   terrainEffect.toolTextureInfo = 
   [UtilityTextureLoader 
    textureWithCGImage:
    [[NSImage imageNamed:@"RadiusSelectionTool.png"] 
     CGImageForProposedRect:NULL context:nil hints:nil]
    options:nil 
    error:NULL]; 
   
   self.modelEffect = [[[TEModelEffect alloc] init] autorelease];
   modelEffect.globalAmbientLightColor = 
   UtilityVector4Make(0.5, 0.5, 0.5, 1.0);
   
   self.pickTerrainEffect = [[[TEPickTerrainEffect alloc] 
                              initWithTerrain:[self.dataSource terrain]] autorelease];
   
   [self startAnimating:nil];
   
   [[NSNotificationCenter defaultCenter]
    postNotificationName:NSUndoManagerCheckpointNotification
    object:undoManager];
   [undoManager enableUndoRegistration];
}


#pragma mark - OpenGL based drawing & update

/////////////////////////////////////////////////////////////////
//
- (void)prepareOpenGL
{
	[super prepareOpenGL];
	
	// Make this openGL context current to the thread
	// (i.e. all openGL on this thread calls will go to this context)
	[[self openGLContext] makeCurrentContext];
   
   // init GL stuff here
   glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
   glEnable(GL_DEPTH_TEST);
   glEnable(GL_CULL_FACE);
   
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
//
- (void)reshape
{
   [super reshape];
   
   const GLfloat    width = [self bounds].size.width;
   const GLfloat    height = [self bounds].size.height;
   
   NSParameterAssert(0 < height);
   const GLfloat    aspectRatio = width / height;
   
   // Use default frame buffer
   glBindFramebuffer(GL_FRAMEBUFFER, 0);
   
   // Tell OpenGL ES to draw into the full backing area
   glViewport(0, 0, width, height);
   
   // Configure projection and viewing/clipping volume
   [self.camera configurePerspectiveProjectionWithAspectRatio:
    aspectRatio];
   self.modelEffect.projectionMatrix = self.camera.projectionMatrix;
   self.modelEffect.modelviewMatrix = UtilityMatrix4Identity;
   self.modelEffect.diffuseLightDirection = 
   TEDefaultTerrainLightDirection;
   
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
//
- (void)updateDetailTextureMatrices
{
   const float constWidthMeters = 
   self.dataSource.terrain.widthMeters;
   const float constLengthMeters = 
   self.dataSource.terrain.lengthMeters;
   const float constMetersPerUnit = 
   [self.dataSource.terrain.metersPerUnit floatValue];
   
   NSAssert(0 < constWidthMeters, 
            @"Invalid terrain.widthMeters");
   NSAssert(0 < constLengthMeters, 
            @"Invalid terrain.lengthMeters");
   NSAssert(0 < constMetersPerUnit, 
            @"Invalid terrain.metersPerUnit");
   
   {  // detail texture 0
      float widthScalefactor = 
      [self.dataSource.terrain.detailTextureScale0 floatValue] / 
      constMetersPerUnit;
      widthScalefactor = MAX(widthScalefactor, 
                             1.0f / constWidthMeters);
      float lengthScalefactor = 
      [self.dataSource.terrain.detailTextureScale0 floatValue] / 
      constMetersPerUnit;
      lengthScalefactor = MAX(lengthScalefactor, 
                              1.0f / self.dataSource.terrain.lengthMeters);
      
      self.terrainEffect.textureMatrix0 = 
      UtilityMatrix3MakeScale(widthScalefactor, 
                              1.0f, 
                              lengthScalefactor);
   }
   {  // detail texture 1  
      float widthScalefactor = 
      [self.dataSource.terrain.detailTextureScale1 floatValue] / 
      constMetersPerUnit;
      widthScalefactor = MAX(widthScalefactor, 
                             1.0f / constWidthMeters);
      float lengthScalefactor = 
      [self.dataSource.terrain.detailTextureScale1 floatValue] / 
      constMetersPerUnit;
      lengthScalefactor = MAX(lengthScalefactor, 
                              1.0f / self.dataSource.terrain.lengthMeters);
      
      self.terrainEffect.textureMatrix1 = 
      UtilityMatrix3MakeScale(widthScalefactor, 
                              1.0f, 
                              lengthScalefactor);
   }
   {  // detail texture 2  
      float widthScalefactor = 
      [self.dataSource.terrain.detailTextureScale2 floatValue] / 
      constMetersPerUnit;
      widthScalefactor = MAX(widthScalefactor, 
                             1.0f / constWidthMeters);
      float lengthScalefactor = 
      [self.dataSource.terrain.detailTextureScale2 floatValue] / 
      constMetersPerUnit;
      lengthScalefactor = MAX(lengthScalefactor, 
                              1.0f / self.dataSource.terrain.lengthMeters);
      
      self.terrainEffect.textureMatrix2 = 
      UtilityMatrix3MakeScale(widthScalefactor, 
                              1.0f, 
                              lengthScalefactor);
   }
   {  // detail texture 3  
      float widthScalefactor = 
      [self.dataSource.terrain.detailTextureScale3 floatValue] / 
      constMetersPerUnit;
      widthScalefactor = MAX(widthScalefactor, 
                             1.0f / constWidthMeters);
      float lengthScalefactor = 
      [self.dataSource.terrain.detailTextureScale3 floatValue] / 
      constMetersPerUnit;
      lengthScalefactor = MAX(lengthScalefactor, 
                              1.0f / self.dataSource.terrain.lengthMeters);
      
      self.terrainEffect.textureMatrix3 = 
      UtilityMatrix3MakeScale(widthScalefactor, 
                              1.0f, 
                              lengthScalefactor);
   }
}


/////////////////////////////////////////////////////////////////
//
- (void)update
{
   [super update];
   
   self.terrainEffect.projectionMatrix = self.camera.projectionMatrix;
   self.terrainEffect.modelviewMatrix = self.camera.modelviewMatrix;
   
   if(nil != self.editingLightAndWeightsTextureInfo)
   {
      self.terrainEffect.lightAndWeightsTextureInfo = 
      self.editingLightAndWeightsTextureInfo;
   }
   else
   {
      self.terrainEffect.lightAndWeightsTextureInfo = 
      self.dataSource.terrain.lightAndWeightsTextureInfo;
   }
   
   self.terrainEffect.detailTextureInfo0 = 
   self.dataSource.terrain.detailTextureInfo0;
   self.terrainEffect.detailTextureInfo1 = 
   self.dataSource.terrain.detailTextureInfo1;
   self.terrainEffect.detailTextureInfo2 = 
   self.dataSource.terrain.detailTextureInfo2;
   self.terrainEffect.detailTextureInfo3 = 
   self.dataSource.terrain.detailTextureInfo3;
   
   [self updateDetailTextureMatrices];
   [self.dataSource.currentTool update];
   [self.terrainEffect updateTool];
}


/////////////////////////////////////////////////////////////////
//
- (void)renderTerrain
{
   TETerrain *terrain = [[self dataSource] terrain];
   
	[[self openGLContext] makeCurrentContext];
   
   if(nil == self.tiles)
   {  // Cache tiles
      self.tiles = terrain.tiles;
   }
   
   [self.dataSource.terrain prepareToDraw];
   
   if(self.shouldShowTexture)
   { // Draw textured terrain 
      [self.terrainEffect prepareToDraw];   
      [self.dataSource.terrain drawTiles:self.tiles];
   }
   
   if(self.shouldShowGrid)
   { // Draw terrain grid lines 
      UtilityVector4 savedColor = 
      self.terrainEffect.globalAmbientLightColor;
      self.terrainEffect.globalAmbientLightColor = 
      UtilityVector4Make(
                         0.0, 1.0, 0.0, 1.0);
      [self.terrainEffect prepareToDraw];   
      [self.dataSource.terrain drawTileLines:self.tiles];
      self.terrainEffect.globalAmbientLightColor = savedColor;
   }
}


/////////////////////////////////////////////////////////////////
//
- (void)renderModels
{
   TETerrain *terrain = [[self dataSource] terrain];
   
   const float metersPerUnit = [terrain.metersPerUnit floatValue];
   
   NSSet *modelPlacements = 
   self.dataSource.terrain.modelPlacements;
   
   self.modelEffect.texture2D = 
   [[self.dataSource modelManager] textureInfo];
   [[self.dataSource modelManager] prepareToDraw];
   
   self.modelEffect.projectionMatrix =
   self.camera.projectionMatrix;
   
   NSArray *selectedPlacements = 
   modelPlacementArrayController.selectedObjects;
   
   for(TEModelPlacement *currentPlacement in modelPlacements)
   {
      //if(![selectedPlacements containsObject:currentPlacement])
      {
         UtilityVector3 position = {
            [currentPlacement.positionX floatValue] * metersPerUnit,
            [currentPlacement.positionY floatValue],
            [currentPlacement.positionZ floatValue] * metersPerUnit
         };
         
         TEModel *currentModel = [[self.dataSource modelManager] 
                                  modelNamed:currentPlacement.modelName];
         
         UtilityMatrix4 modelviewMatrix = 
         self.camera.modelviewMatrix;
         modelviewMatrix =
         UtilityMatrix4Translate(modelviewMatrix,
                                 position.x, position.y, position.z);
         modelviewMatrix =
         UtilityMatrix4Rotate(modelviewMatrix,
                              UtilityDegreesToRadians * [currentPlacement.angle floatValue],
                              0.0f, 1.0f, 0.0f);
         self.modelEffect.modelviewMatrix = modelviewMatrix;
         
         [self.modelEffect prepareToDraw];
         [currentModel draw];
      }
   }
   
   // Draw selection indicators
   self.modelEffect.texture2D = nil;
   for(TEModelPlacement *currentPlacement in selectedPlacements)
   {
      UtilityVector3 position = {
         [currentPlacement.positionX floatValue] * metersPerUnit,
         [currentPlacement.positionY floatValue],
         [currentPlacement.positionZ floatValue] * metersPerUnit
      };
      
      TEModel *currentModel = [[self.dataSource modelManager] 
                               modelNamed:currentPlacement.modelName];
      
      UtilityMatrix4 modelviewMatrix = 
      self.camera.modelviewMatrix;
      modelviewMatrix =
      UtilityMatrix4Translate(modelviewMatrix,
                              position.x, position.y, position.z);
      modelviewMatrix =
      UtilityMatrix4Rotate(modelviewMatrix,
                           UtilityDegreesToRadians * [currentPlacement.angle floatValue],
                           0.0f, 1.0f, 0.0f);
      self.modelEffect.modelviewMatrix = modelviewMatrix;
      
      [self.modelEffect prepareToDraw];
      [currentModel drawBoundingBox];
   }
}


/////////////////////////////////////////////////////////////////
//
- (void)drawRect:(NSRect)dirtyRect
{
	// Make this openGL context current to the thread
	// (i.e. all openGL on this thread calls will go to this context)
	[[self openGLContext] makeCurrentContext];
   
   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
   
   // Render the terrain
   [self renderTerrain];
   
   // Render models
   [self renderModels];
   
	CGLFlushDrawable([[self openGLContext] CGLContextObj]);
   
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

static const GLfloat TEHeadHeight = (0.2f);

/////////////////////////////////////////////////////////////////
// Camera delegate method
- (void)cameraPositionDidChange:(UtilityOpenGLCamera *)sender;
{
   TETerrain *terrain = [self.dataSource terrain];
   const float metersPerUnit = [terrain.metersPerUnit floatValue];
   
   // Contrain referencePosition to terrain and keep it above
   // terrain height
   referencePosition.x = 
   MIN(MAX(2, referencePosition.x), terrain.widthMeters - 2);
   referencePosition.z = 
   MIN(MAX(2, referencePosition.z), terrain.lengthMeters - 2);
   
   GLfloat terrainHeight = [terrain
                            maxHeightNearXPosMeters:referencePosition.x 
                            zPosMeters:referencePosition.z];
   
   referencePosition.y = terrainHeight + TEHeadHeight;
   
   [self.camera setLookAtPosition:
    UtilityVector3Make(
                       referencePosition.x + cosf(angle) * metersPerUnit, 
                       referencePosition.y + pitchOffset, 
                       referencePosition.z + sinf(angle) * metersPerUnit)];
   
   UtilityVector3 thridPersonEyePosition = 
   UtilityVector3Add(
                     referencePosition, 
                     UtilityVector3Scale(self.camera.forwardVector, 
                                         -(thirdPersonOffset * thirdPersonOffset)));
   thridPersonEyePosition.y += [terrain.metersPerUnit floatValue] *
   thirdPersonOffset * thirdPersonOffset;
   [self.camera setPosition:thridPersonEyePosition];
}


#pragma mark - Editing

/////////////////////////////////////////////////////////////////
//  
- (NSImage *)toolTextureImage
{
   return [self.terrainEffect.toolTextureInfo image];
}

#pragma mark - Animation

/////////////////////////////////////////////////////////////////
//
- (void)runStep:(id)sender
{  
   [self setNeedsDisplay:YES];
   
   if(self.isAnimating)
   {
      [self performSelector:@selector(runStep:) withObject:nil 
                 afterDelay:1.0/30.0];
   }
   
   [self update];
}


/////////////////////////////////////////////////////////////////
//
- (IBAction)startAnimating:(id)sender
{
   self.isAnimating = YES;
   [self runStep:nil];
}


/////////////////////////////////////////////////////////////////
//
- (IBAction)stopAnimating:(id)sender
{
   self.isAnimating = NO;
   [NSApplication cancelPreviousPerformRequestsWithTarget:self];
}


/////////////////////////////////////////////////////////////////
//
- (IBAction)takeShouldShowTextureFrom:(id)sender;
{
   self.shouldShowTexture = [sender boolValue];
}


/////////////////////////////////////////////////////////////////
//
- (IBAction)takeShouldShowGridFrom:(id)sender;
{
   self.shouldShowGrid = [sender boolValue];
}

#pragma mark - User input


/////////////////////////////////////////////////////////////////
//
- (void)keyDown:(NSEvent *)theEvent
{
   TETerrain *terrain = [self.dataSource terrain];
   const float metersPerUnit = [terrain.metersPerUnit floatValue];
   const float offset = 
   MAX(MIN(self.thirdPersonOffset, 8.0f), 1.0f);
   const float motionScaleFactor = metersPerUnit * 
   offset * offset;
   NSString *keys = [theEvent charactersIgnoringModifiers];
   unichar character = [keys characterAtIndex:0];
   
   if(character == 'w')
   {
      referencePosition = 
      UtilityVector3Add(referencePosition, 
                        UtilityVector3Scale(self.camera.forwardVector, 
                                            motionScaleFactor));
   }
   else if(character == 'a')
   {
      referencePosition = 
      UtilityVector3Add(referencePosition, 
                        UtilityVector3Scale(self.camera.rightVector, 
                                            -motionScaleFactor));
   }
   else if(character == 'd')
   {
      referencePosition = 
      UtilityVector3Add(referencePosition, 
                        UtilityVector3Scale(self.camera.rightVector, 
                                            motionScaleFactor));
   }
   else if(character == 's')
   {
      referencePosition = 
      UtilityVector3Add(referencePosition, 
                        UtilityVector3Scale(self.camera.forwardVector, 
                                            -motionScaleFactor));
   }
   
   self.camera.position = referencePosition;
   
   [self setNeedsDisplay:YES];
}


/////////////////////////////////////////////////////////////////
//
- (void)renderTerrainForPicking
{
   TETerrain *terrain = self.dataSource.terrain;
   
   if(nil == self.tiles)
   {  // Cache tiles
      self.tiles = terrain.tiles;
   }
   
   // Render terrain for picking
   [terrain prepareToDraw];
   
   self.pickTerrainEffect.modelIndex = 0;
   self.pickTerrainEffect.projectionMatrix = 
   self.camera.projectionMatrix;
   self.pickTerrainEffect.modelviewMatrix = 
   self.camera.modelviewMatrix;
   [self.pickTerrainEffect prepareToDraw];   
   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
   [self.dataSource.terrain drawTiles:self.tiles];
   
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
//
- (void)renderModelForPicking
{
   TETerrain *terrain = self.dataSource.terrain;
   
   self.pickTerrainEffect.texture2D = 
   [[self.dataSource modelManager] textureInfo];
   
   const float metersPerUnit = [terrain.metersPerUnit floatValue];
   NSSet *modelPlacements = 
   self.dataSource.terrain.modelPlacements;
   
   [[self.dataSource modelManager] prepareToDraw];
   
   unsigned char index = 1;
   for(TEModelPlacement *currentPlacement in modelPlacements)
   {
      UtilityVector3 position = {
         [currentPlacement.positionX floatValue] * metersPerUnit,
         [currentPlacement.positionY floatValue],
         [currentPlacement.positionZ floatValue] * metersPerUnit
      };
      
      TEModel *currentModel = 
      [[self.dataSource modelManager] 
       modelNamed:currentPlacement.modelName];
      
      UtilityMatrix4 modelviewMatrix = 
      self.camera.modelviewMatrix;
      modelviewMatrix =
      UtilityMatrix4Translate(modelviewMatrix,
                              position.x, position.y, position.z);
      modelviewMatrix =
      UtilityMatrix4Rotate(modelviewMatrix,
                           UtilityDegreesToRadians * [currentPlacement.angle floatValue],
                           0.0f, 1.0f, 0.0f);
      self.pickTerrainEffect.modelviewMatrix = modelviewMatrix;
      
      self.pickTerrainEffect.modelIndex = index;
      [self.pickTerrainEffect prepareToDraw];
      [currentModel draw];
      
      currentPlacement.index = 
      [NSNumber numberWithInteger:index];
      index++;
   }
   
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
//
- (TEPickTerrainInfo)pickLocationForMousePosition:(NSPoint)aPos
{
   NSUndoManager *undoManager = [self undoManager];
   [[NSNotificationCenter defaultCenter]
    postNotificationName:NSUndoManagerCheckpointNotification
    object:undoManager];
   [undoManager disableUndoRegistration];
   
	[[self openGLContext] makeCurrentContext];
   
   // Render pick terrain
   [self renderTerrainForPicking];
   
   // Render models for picking
   [self renderModelForPicking];
   
   // Get info for picked location
   const UtilityVector2 scaledMouseLocation = {
      aPos.x / self.bounds.size.width,
      aPos.y / self.bounds.size.height
   };
   
   const GLfloat width = [self bounds].size.width;
   const GLfloat height = [self bounds].size.height;
   
   NSAssert(0 < height, @"Invalid height");
   const GLfloat    aspectRatio = width / height;
   
   const TEPickTerrainInfo pickInfo = 
   [self.pickTerrainEffect positionAtMouseLocation:
    scaledMouseLocation
                                       aspectRatio:aspectRatio];
   [self reshape];  // needed because -positionAtMouseLocation
                    // changes viewport()
   
   //NSLog(@"pickInfo {{%f, %f}, %d}", pickInfo.position.x,
   //      pickInfo.position.y, pickInfo.modelIndex);
   
   [[NSNotificationCenter defaultCenter]
    postNotificationName:NSUndoManagerCheckpointNotification
    object:undoManager];
   [undoManager enableUndoRegistration];
   
   return pickInfo;
}


/////////////////////////////////////////////////////////////////
//
- (void)mouseDown:(NSEvent *)theEvent
{
   NSUndoManager *undoManager = [self.dataSource undoManager];
   [undoManager beginUndoGrouping];
   
	// Make this openGL context current to the thread
	// (i.e. all openGL on this thread calls will go to this context)
	[[self openGLContext] makeCurrentContext];
   
   NSPoint mousePosition = 
   [self convertPoint:[theEvent locationInWindow]
             fromView:nil];
   
   TEPickTerrainInfo pickInfo = 
   [self pickLocationForMousePosition:mousePosition];
   
   if(0 == pickInfo.modelIndex)
   { // Deselect model placements
      [self.modelPlacementArrayController setSelectedObjects:
       [NSArray array]];
      
      // Move tool
      self.terrainEffect.toolLocation = 
      pickInfo.position;
   }
   else
   { // Select picked model placement
      NSSet *modelPlacements = 
      self.dataSource.terrain.modelPlacements;
      
      for(TEModelPlacement *currentPlacement in modelPlacements)
      {
         if(pickInfo.modelIndex == 
            [currentPlacement.index integerValue])
         {
            [self.modelPlacementArrayController setSelectedObjects:
             [NSArray arrayWithObject:currentPlacement]];
         }
      }
   }
   
   // Tell tool about change
   [self.dataSource.currentTool mouseDown:theEvent]; 
   
   [self setNeedsDisplay:YES];
}


/////////////////////////////////////////////////////////////////
//
- (void)mouseDragged:(NSEvent *)theEvent
{
	// Make this openGL context current to the thread
	// (i.e. all openGL on this thread calls will go to this context)
	[[self openGLContext] makeCurrentContext];
   
   if(nil == self.editingLightAndWeightsTextureInfo)
   {
      self.editingLightAndWeightsTextureInfo = 
      [[self.dataSource.terrain.lightAndWeightsTextureInfo 
        copy] autorelease];
   }
   
   NSPoint mousePosition = 
      [self convertPoint:[theEvent locationInWindow]
             fromView:nil];
   
   TEPickTerrainInfo pickInfo = 
      [self pickLocationForMousePosition:mousePosition];
   self.terrainEffect.toolLocation = 
      pickInfo.position;
   [self.dataSource.currentTool mouseDragged:theEvent]; 
   
   self.terrainEffect.lightAndWeightsTextureInfo = 
   self.editingLightAndWeightsTextureInfo;
   
   [self setNeedsDisplay:YES];
}


/////////////////////////////////////////////////////////////////
//
- (void)mouseUp:(NSEvent *)theEvent
{
	// Make this openGL context current to the thread
	// (i.e. all openGL on this thread calls will go to this context)
	[[self openGLContext] makeCurrentContext];
   
   if(nil != self.editingLightAndWeightsTextureInfo)
   {
      self.dataSource.terrain.lightAndWeightsTextureInfo =
         self.editingLightAndWeightsTextureInfo;
      self.editingLightAndWeightsTextureInfo = nil;
      self.terrainEffect.lightAndWeightsTextureInfo = 
         self.dataSource.terrain.lightAndWeightsTextureInfo;
   }
   [self.dataSource.currentTool mouseUp:theEvent]; 
   
   [self setNeedsDisplay:YES];
      
   NSUndoManager *undoManager = [self.dataSource undoManager];
   [undoManager endUndoGrouping];
}


/////////////////////////////////////////////////////////////////
//
- (void)otherMouseDragged:(NSEvent *)theEvent
{
   angle += -0.01f * [theEvent deltaX];
   
   NSPoint mousePosition = 
   [self convertPoint:[theEvent locationInWindow]
             fromView:nil];
   
   pitchOffset = (mousePosition.y - NSMidY(self.bounds)) /
   self.bounds.size.height;
   pitchOffset *= 10.0f;
   pitchOffset = MAX(MIN(9.0f, pitchOffset), -9.0f);
   
   self.camera.position = referencePosition;
   
   [self setNeedsDisplay:YES];
}


/////////////////////////////////////////////////////////////////
//
- (void)scrollWheel:(NSEvent *)theEvent
{
   angle += 0.01f * [theEvent deltaX];
   
   thirdPersonOffset += -0.01f * [theEvent deltaY];
   thirdPersonOffset = MAX(MIN(thirdPersonOffset, 8.0f), 0.0f);
   
   self.camera.position = referencePosition;
   
   [self setNeedsDisplay:YES];
}

@end
