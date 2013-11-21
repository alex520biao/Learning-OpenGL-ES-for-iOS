//
//  OpenGLES_Ch4_2ViewController.m
//  OpenGLES_Ch4_2
//

#import "OpenGLES_Ch4_2ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

/////////////////////////////////////////////////////////////////
// This data type is used to store information for each vertex
typedef struct {
   GLKVector3  position;
   GLKVector2  textureCoords;
}
SceneVertex;


/////////////////////////////////////////////////////////////////
// This data type is used to store information for triangles
typedef struct {
   SceneVertex vertices[3];
}
SceneTriangle;


/////////////////////////////////////////////////////////////////
// Define the positions and texture coords of each vertex in the 
// example.
static SceneVertex vertexA = {{-0.5,  0.5, -0.5}, {0.0, 1.0}};
static SceneVertex vertexB = {{-0.5,  0.0, -0.5}, {0.0, 0.5}};
static SceneVertex vertexC = {{-0.5, -0.5, -0.5}, {0.0, 0.0}};
static SceneVertex vertexD = {{ 0.0,  0.5, -0.5}, {0.5, 1.0}};
static SceneVertex vertexE = {{ 0.0,  0.0,  0.0}, {0.5, 0.5}};
static SceneVertex vertexF = {{ 0.0, -0.5, -0.5}, {0.5, 0.0}};
static SceneVertex vertexG = {{ 0.5,  0.5, -0.5}, {1.0, 1.0}};
static SceneVertex vertexH = {{ 0.5,  0.0, -0.5}, {1.0, 0.5}};
static SceneVertex vertexI = {{ 0.5, -0.5, -0.5}, {1.0, 0.0}};


/////////////////////////////////////////////////////////////////
// Forward function declarations
static SceneTriangle SceneTriangleMake(
   const SceneVertex vertexA, 
   const SceneVertex vertexB, 
   const SceneVertex vertexC);


#pragma mark - OpenGLES_Ch4_2ViewController

/////////////////////////////////////////////////////////////////
@interface OpenGLES_Ch4_2ViewController ()
{
   SceneTriangle triangles[8];
}

@end


@implementation OpenGLES_Ch4_2ViewController

@synthesize baseEffect;
@synthesize vertexBuffer;
@synthesize blandTextureInfo;
@synthesize interestingTextureInfo;
@synthesize shouldUseDetailLighting;


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
   
   // Create an OpenGL ES 2.0 context and provide it to the
   // view
   view.context = [[AGLKContext alloc] 
      initWithAPI:kEAGLRenderingAPIOpenGLES2];
   
   // Make the new context current
   [AGLKContext setCurrentContext:view.context];
   
   // Create a base effect that provides standard OpenGL ES 2.0
   // shading language programs and set constants to be used for 
   // all subsequent rendering
   self.baseEffect = [[GLKBaseEffect alloc] init];
   self.baseEffect.useConstantColor = GL_TRUE;
   self.baseEffect.constantColor =
      GLKVector4Make(1.0, 1.0, 1.0, 1.0); // White

   {  // Comment out this block to render the scene top down
      GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(
         GLKMathDegreesToRadians(-60.0f), 1.0f, 0.0f, 0.0f);
      modelViewMatrix = GLKMatrix4Rotate(
         modelViewMatrix,
         GLKMathDegreesToRadians(-30.0f), 0.0f, 0.0f, 1.0f);
      modelViewMatrix = GLKMatrix4Translate(
         modelViewMatrix,
         0.0f, 0.0f, 0.25f);
         
      self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
   }
     
   // Setup texture
   CGImageRef blandSimulatedLightingImageRef = 
      [[UIImage imageNamed:@"Lighting256x256.png"] CGImage];
      
   blandTextureInfo = [GLKTextureLoader 
      textureWithCGImage:blandSimulatedLightingImageRef 
      options:[NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:YES], 
         GLKTextureLoaderOriginBottomLeft, nil] 
      error:NULL];
      
   CGImageRef interestingSimulatedLightingImageRef = 
      [[UIImage imageNamed:@"LightingDetail256x256.png"] CGImage];
      
   interestingTextureInfo = [GLKTextureLoader 
      textureWithCGImage:interestingSimulatedLightingImageRef 
      options:[NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:YES], 
         GLKTextureLoaderOriginBottomLeft, nil] 
      error:NULL];
      
   // Set the background color stored in the current context 
   ((AGLKContext *)view.context).clearColor = GLKVector4Make(
      0.0f, // Red 
      0.0f, // Green 
      0.0f, // Blue 
      1.0f);// Alpha 

   triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
   triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
   triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
   triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
   triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
   triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
   triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
   triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
   
   // Create vertex buffer containing vertices to draw
   self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]
      initWithAttribStride:sizeof(SceneVertex)
      numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)
      bytes:triangles
      usage:GL_DYNAMIC_DRAW]; 
      
   self.shouldUseDetailLighting = YES;
}


/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
   if(self.shouldUseDetailLighting)
   {
      self.baseEffect.texture2d0.name = 
         interestingTextureInfo.name;
      self.baseEffect.texture2d0.target = 
         interestingTextureInfo.target;
   }
   else
   {
      self.baseEffect.texture2d0.name = 
         blandTextureInfo.name;
      self.baseEffect.texture2d0.target = 
         blandTextureInfo.target;
   }
      
   [self.baseEffect prepareToDraw];
   
   // Clear back frame buffer (erase previous drawing)
   [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
   
   [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
      numberOfCoordinates:3
      attribOffset:offsetof(SceneVertex, position)
      shouldEnable:YES];
   [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
      numberOfCoordinates:2
      attribOffset:offsetof(SceneVertex, textureCoords)
      shouldEnable:YES];
      
   // Draw triangles using vertices in the currently bound vertex
   // buffer
   [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
      startVertexIndex:0
      numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)];
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
    
   // Delete buffers that aren't needed when view is unloaded
   self.vertexBuffer = nil;
   
   // Stop using the context created in -viewDidLoad
   ((GLKView *)self.view).context = nil;
   [EAGLContext setCurrentContext:nil];
}


#pragma mark - Actions

/////////////////////////////////////////////////////////////////
// This method sets the value of shouldUseFaceNormals to the 
// value obtained from sender
- (IBAction)takeShouldUseDetailLightingFrom:(UISwitch *)sender;
{
   self.shouldUseDetailLighting = sender.isOn; 
}

@end


#pragma mark - Triangle manipulation

/////////////////////////////////////////////////////////////////
// This function returns a triangle composed of the specified
// vertices.
static SceneTriangle SceneTriangleMake(
   const SceneVertex vertexA, 
   const SceneVertex vertexB, 
   const SceneVertex vertexC)
{
   SceneTriangle   result;
   
   result.vertices[0] = vertexA;
   result.vertices[1] = vertexB;
   result.vertices[2] = vertexC;
   
   return result;
} 
