//
//  CVView.m
//  COLLADAViewer
//

#import "CVView.h"
#import "CVDocument.h"
#import "COLLADANode.h"
#import "CVMesh.h"
#import "CVModel.h"
#import "UtilityTextureLoader.h"
#import "UtilityOpenGLCamera.h"
#import "UtilityVector.h"


@interface CVView ()

@property (nonatomic, assign, readwrite) 
   BOOL isAnimating;
@property (nonatomic, assign, readwrite) 
   float modelRotationAngleDeg;
@property (nonatomic, retain, readwrite) 
   UtilityOpenGLCamera *camera;

@end


@implementation CVView

@synthesize dataSource = dataSource_;
@synthesize isAnimating = isAnimating_;
@synthesize camera = camera_;
@synthesize modelRotationAngleDeg = modelRotationAngleDeg_;
@synthesize normalLineLengthForDisplay = normalLineLengthForDisplay_;


/////////////////////////////////////////////////////////////////
//
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
    }
    
    return self;
}


/////////////////////////////////////////////////////////////////
//
- (void)initGL
{
   if(nil == self.camera)
   {
      // Camera used for placed blocks on game board
      self.camera = [[[UtilityOpenGLCamera alloc] init] autorelease];
      [self.camera setPosition:UtilityVector3Make(
         10.0f, 10.0f, 10.0f)];
      [self.camera setLookAtPosition:UtilityVector3Make(
         0.0f, 0.0f, 0.0f)];
   }
}


/////////////////////////////////////////////////////////////////
//
- (void)awakeFromNib
{
   [self initGL];
   normalLineLengthForDisplay_ = 0.2f;
}


/////////////////////////////////////////////////////////////////
//
- (void)configureCurrentMaterial
{
   GLfloat   diffuseColorComponents[4];
   diffuseColorComponents[0] = 1.0f;
   diffuseColorComponents[1] = 1.0f;
   diffuseColorComponents[2] = 1.0f;
   diffuseColorComponents[3] = 1.0f;  // Opaque      
   glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, 
      diffuseColorComponents);
   
   GLfloat   specularColorComponents[4];
   specularColorComponents[0] = 0.0f;
   specularColorComponents[1] = 0.0f;
   specularColorComponents[2] = 0.0f;
   specularColorComponents[3] = 0.0f;  // Opaque      
   glMaterialfv(GL_FRONT, GL_SPECULAR, 
      specularColorComponents);
}


/////////////////////////////////////////////////////////////////
//
- (void)configureLights
{
   // Attributes of light sources (arbitrary)
   static const GLfloat defaultAmbient[] = {0.4, 0.4, 0.4, 1.0};
   static const GLfloat defaultDiffuse[] = {0.7, 0.7, 0.7, 1.0};
   static const GLfloat defaultSpecular[] = {0.0, 0.0, 0.0, 1.0};
   
   // Lighting
   glLightfv(GL_LIGHT0, GL_AMBIENT, defaultAmbient);   
   glLightfv(GL_LIGHT0, GL_DIFFUSE, defaultDiffuse); 
   glLightfv(GL_LIGHT0, GL_SPECULAR, defaultSpecular); 
   glEnable(GL_LIGHT0);                   
   
   // Needed for correct lighting when scaled or in perspective
   // Still requires uniform scale (identical scale amount on all 
   // axes)
   glEnable(GL_RESCALE_NORMAL);
   
   static const GLfloat generalLightDirection[] = 
      {1.0f, 0.5f, 0.0f, 0.0f};
   glLightfv(GL_LIGHT0, 
             GL_POSITION,      
             generalLightDirection);
}


/////////////////////////////////////////////////////////////////
//
- (void)drawZAxis
{
   glDisable(GL_LIGHTING);
   glDisable(GL_TEXTURE_2D);

   glColor4f(0.0f, 1.0f, 1.0f, 1.0f);
   
   glDisableClientState(GL_VERTEX_ARRAY);                 
   glDisableClientState(GL_NORMAL_ARRAY); 
   glDisableClientState(GL_TEXTURE_COORD_ARRAY);
   
   GLfloat   vertexBuffer[6];
   
   vertexBuffer[0] = 0;
   vertexBuffer[1] = 0;
   vertexBuffer[2] = 0;
   vertexBuffer[3] = 0;
   vertexBuffer[4] = 0;
   vertexBuffer[5] = -1000;
   
   glEnableClientState(GL_VERTEX_ARRAY);                 
   glVertexPointer(3, 
      GL_FLOAT, 
      3 * sizeof(GLfloat), 
      vertexBuffer);
   glDrawArrays(GL_LINES, 0, 2);
}


/////////////////////////////////////////////////////////////////
//
- (void)setNormalLineLengthForDisplay:(GLfloat)aLength
{
   normalLineLengthForDisplay_ = aLength;
   [self setNeedsDisplay:YES];
}


/////////////////////////////////////////////////////////////////
//
- (void)drawSelectedModelNormalsAtIndex:(NSUInteger)index
{
   CVModel *model = [[self.dataSource allModels] 
      objectAtIndex:index];
   
   [model drawNormalsLength:self.normalLineLengthForDisplay];
}


/////////////////////////////////////////////////////////////////
//
- (void)drawSelectedModelAtIndex:(NSUInteger)index
{
   CVModel *model = [[self.dataSource allModels] 
      objectAtIndex:index];
   
   [model draw];
}


/////////////////////////////////////////////////////////////////
//
- (void)drawSelectedModels
{
   glBindTexture (GL_TEXTURE_2D, [self.dataSource.textureInfo name]); 
   glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

   [self.dataSource.consolidatedMesh prepareToDraw];

   NSIndexSet *selectedRootNodes = [self.dataSource selectedModels];
   
   {
      [selectedRootNodes 
         enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop)
      {
         [self drawSelectedModelAtIndex:index];      
      }];
   }
   
   if([self.dataSource shouldShowNormals])
   {
      [selectedRootNodes 
         enumerateIndexesUsingBlock:^(NSUInteger index, 
            BOOL *stop)
      {
         [self drawSelectedModelNormalsAtIndex:index];      
      }];
   }
}


/////////////////////////////////////////////////////////////////
//
- (void)drawRect:(NSRect)dirtyRect
{
   const GLfloat    width = [self bounds].size.width;
   const GLfloat    height = [self bounds].size.height;
   
   NSParameterAssert(0 < height);
   const GLfloat    aspectRatio = width / height;
   
   // Tell OpenGL ES to draw into the full backing area
   glViewport(0, 0, width, height);
   
   glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
   glEnable(GL_DEPTH_TEST);
   glDisable(GL_COLOR_MATERIAL);
   glEnable(GL_CULL_FACE);
   glEnable(GL_BLEND);
   glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
   glEnable(GL_ALPHA_TEST);
   glAlphaFunc(GL_GREATER, 0.5f);
      
   // Configure projection and viewing/clipping volume
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   [self.camera configurePerspectiveProjectionWithAspectRatio:
      aspectRatio];

   // Configure projection and viewing/clipping volume
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
   [self.camera configureModelView];
   [self configureLights];
   
   glPushMatrix();
   {
      if([self.dataSource shouldRotateModel])
      {
         UtilityVector3 upVector = [self.camera upVector];
         glRotatef(-self.modelRotationAngleDeg, 
            upVector.x, upVector.y, upVector.z);  
         self.modelRotationAngleDeg += 0.5f;
      }

      // Draw the models
      [self drawSelectedModels];
   }
   glPopMatrix();
   
   if([self.dataSource shouldShowNegativeZAxis])
   {
      // Draw -Z axis
      [self drawZAxis];
   }
   
   // Flush drawing commands to GPU and screen
	[[self openGLContext] flushBuffer];
}


/////////////////////////////////////////////////////////////////
//
- (void)keyDown:(NSEvent *)theEvent
{
   NSString   *keys = [theEvent characters];
   
   if('-' == [keys characterAtIndex:0])
   {
      [self setNeedsDisplay:YES];
      [self.camera setDistanceFromLookAtPosition:
         [self.camera distanceFromLookAtPosition] + 5.0f];
   }
   else if('+' == [keys characterAtIndex:0])
   {
      [self setNeedsDisplay:YES];
      [self.camera setDistanceFromLookAtPosition:
         [self.camera distanceFromLookAtPosition] - 5.0f];
   }
}


/////////////////////////////////////////////////////////////////
//
- (void)scrollWheel:(NSEvent *)theEvent
{
   float  deltaY = [theEvent deltaY];
   float  distanceFromLookAtPosition = 
      [self.camera distanceFromLookAtPosition];
   
   [self.camera setDistanceFromLookAtPosition:-deltaY + 
      distanceFromLookAtPosition];
   [self setNeedsDisplay:YES];
}


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
}

@end
