//
//  OpenGLES_Ch4_1ViewController.m
//  OpenGLES_Ch4_1
//

#import "OpenGLES_Ch4_1ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"


/////////////////////////////////////////////////////////////////
// This data type is used to store information for each vertex
typedef struct {
   GLKVector3  position;
   GLKVector3  normal;
}
SceneVertex;


/////////////////////////////////////////////////////////////////
// This data type is used to store information for triangles
typedef struct {
   SceneVertex vertices[3];
}
SceneTriangle;


/////////////////////////////////////////////////////////////////
// Define the positions and normal vectors of each vertex in the 
// example.
static const SceneVertex vertexA = 
   {{-0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexB = 
   {{-0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexC = 
   {{-0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexD = 
   {{ 0.0,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexE = 
   {{ 0.0,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexF = 
   {{ 0.0, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexG = 
   {{ 0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexH = 
   {{ 0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexI = 
   {{ 0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};


/////////////////////////////////////////////////////////////////
// The scene to be rendered is composed of 8 triangles. There are
// 4 triangles in the pyramid itself and othe 4 horizontal
// triangles represent a base for teh pyramid.
#define NUM_FACES (8)

/////////////////////////////////////////////////////////////////
// 48 vertices are needed to draw all of the normal vectors: 
//    8 triangles * 3 vertices per triangle = 24 vertices
//    24 vertices * 1 normal vector per vertex * 2 vertices to
//       draw each normal vector = 48 vertices
#define NUM_NORMAL_LINE_VERTS (48)

/////////////////////////////////////////////////////////////////
// 50 vertices are needed to draw all of the normal vectors 
// and the light direction vector: 
//    8 triangles * 3 vertices per triangle = 24 vertices
//    24 vertices * 1 normal vector per vertex * 2 vertices to
//       draw each normal vector = 48 vertices
//    plus 2 vertices to draw the light direction = 50 
#define NUM_LINE_VERTS (NUM_NORMAL_LINE_VERTS + 2)

/////////////////////////////////////////////////////////////////
// Forward function declarations
static SceneTriangle SceneTriangleMake(
   const SceneVertex vertexA, 
   const SceneVertex vertexB, 
   const SceneVertex vertexC);

static GLKVector3 SceneTriangleFaceNormal(
   const SceneTriangle triangle);

static void SceneTrianglesUpdateFaceNormals(
   SceneTriangle someTriangles[NUM_FACES]);

static void SceneTrianglesUpdateVertexNormals(
   SceneTriangle someTriangles[NUM_FACES]);

static  void SceneTrianglesNormalLinesUpdate(
   const SceneTriangle someTriangles[NUM_FACES],
   GLKVector3 lightPosition,
   GLKVector3 someNormalLineVertices[NUM_LINE_VERTS]);

static  GLKVector3 SceneVector3UnitNormal(
   const GLKVector3 vectorA, 
   const GLKVector3 vectorB);
   
   
#pragma mark - OpenGLES_Ch4_1ViewController

/////////////////////////////////////////////////////////////////
@interface OpenGLES_Ch4_1ViewController ()
{
   SceneTriangle triangles[NUM_FACES];
}

@end


@implementation OpenGLES_Ch4_1ViewController

@synthesize baseEffect;
@synthesize extraEffect;
@synthesize vertexBuffer;
@synthesize extraBuffer;
@synthesize centerVertexHeight;
@synthesize shouldUseFaceNormals;
@synthesize shouldDrawNormals;


/////////////////////////////////////////////////////////////////
// Called recalculate the normal vectors for the receiver's 
// triangles using either face normals or averaged vertex normals.
- (void)updateNormals
{
   if(self.shouldUseFaceNormals)
   {  // Use face normal vectors to produce facets effect
      // Lighting Step 3
      SceneTrianglesUpdateFaceNormals(triangles);   
   }
   else 
   {  // Interpolate normal vectors for smooth rounded effect
      // Lighting Step 3
      SceneTrianglesUpdateVertexNormals(triangles); 
   }
      
   // Reinitialize the vertex buffer containing vertices to draw
   [self.vertexBuffer
      reinitWithAttribStride:sizeof(SceneVertex)
      numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)
      bytes:triangles];   
}


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
   // Shading Language programs and set constants to be used for 
   // all subsequent rendering
   self.baseEffect = [[GLKBaseEffect alloc] init];
   self.baseEffect.light0.enabled = GL_TRUE;
   self.baseEffect.light0.diffuseColor = GLKVector4Make(
      0.7f, // Red 
      0.7f, // Green 
      0.7f, // Blue 
      1.0f);// Alpha 
   self.baseEffect.light0.position = GLKVector4Make(
      1.0f,  
      1.0f,  
      0.5f,  
      0.0f);

   extraEffect = [[GLKBaseEffect alloc] init];
   self.extraEffect.useConstantColor = GL_TRUE;
   self.extraEffect.constantColor = GLKVector4Make(
      0.0f, // Red 
      1.0f, // Green 
      0.0f, // Blue 
      1.0f);// Alpha 

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
      self.extraEffect.transform.modelviewMatrix = modelViewMatrix;
   }      
       
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

   // Create extra buffer for drawing lines showing normals
   self.extraBuffer = [[AGLKVertexAttribArrayBuffer alloc]
      initWithAttribStride:sizeof(SceneVertex)
      numberOfVertices:0
      bytes:NULL
      usage:GL_DYNAMIC_DRAW];   

   self.centerVertexHeight = 0.0f;
   self.shouldUseFaceNormals = YES;
}


/////////////////////////////////////////////////////////////////
// This method draws lines to represent the normal vectors and
// light direction
- (void)drawNormals
{
   GLKVector3  normalLineVertices[NUM_LINE_VERTS];
   
   // calculate all 50 vertices based on 8 triangles
   SceneTrianglesNormalLinesUpdate(triangles, 
      GLKVector3MakeWithArray(self.baseEffect.light0.position.v),
      normalLineVertices);

   [self.extraBuffer reinitWithAttribStride:sizeof(GLKVector3) 
      numberOfVertices:NUM_LINE_VERTS
      bytes:normalLineVertices];
   
   [self.extraBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
      numberOfCoordinates:3
      attribOffset:0
      shouldEnable:YES];
   
   // Draw lines to represent normal vectors and light direction
   // Don't use light so that line color shows   
   self.extraEffect.useConstantColor = GL_TRUE;
   self.extraEffect.constantColor =
      GLKVector4Make(0.0, 1.0, 0.0, 1.0); // Green
       
   [self.extraEffect prepareToDraw];
   
   [self.extraBuffer drawArrayWithMode:GL_LINES 
      startVertexIndex:0 
      numberOfVertices:NUM_NORMAL_LINE_VERTS];
      
   self.extraEffect.constantColor =
      GLKVector4Make(1.0, 1.0, 0.0, 1.0); // Yellow
       
   [self.extraEffect prepareToDraw];
   
   [self.extraBuffer drawArrayWithMode:GL_LINES 
      startVertexIndex:NUM_NORMAL_LINE_VERTS 
      numberOfVertices:(NUM_LINE_VERTS - NUM_NORMAL_LINE_VERTS)];
}


/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
   [self.baseEffect prepareToDraw];
   
   // Clear back frame buffer (erase previous drawing)
   [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
   
   [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
      numberOfCoordinates:3
      attribOffset:offsetof(SceneVertex, position)
      shouldEnable:YES];
   [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal
      numberOfCoordinates:3
      attribOffset:offsetof(SceneVertex, normal)
      shouldEnable:YES];
      
   // Draw triangles using vertices in the currently bound vertex
   // buffer
   [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
      startVertexIndex:0
      numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)];
      
   if(self.shouldDrawNormals)
   {
      [self drawNormals];
   }
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
- (IBAction)takeShouldUseFaceNormalsFrom:(UISwitch *)sender;
{
   self.shouldUseFaceNormals = sender.isOn; 
}


/////////////////////////////////////////////////////////////////
// This method sets the value of shouldUseFaceNormals to the 
// value obtained from sender
- (IBAction)takeShouldDrawNormalsFrom:(UISwitch *)sender;
{
   self.shouldDrawNormals = sender.isOn;
}


/////////////////////////////////////////////////////////////////
// This method sets the value of the center vertex height to the 
// value obtained from sender
- (IBAction)takeCenterVertexHeightFrom:(UISlider *)sender;
{
   self.centerVertexHeight = sender.value;
}


#pragma mark - Accessors with side effects

/////////////////////////////////////////////////////////////////
// This method returns the value of centerVertexHeight.
- (GLfloat)centerVertexHeight
{
   return centerVertexHeight;
}


/////////////////////////////////////////////////////////////////
// This method sets the value of centerVertexHeight and updates
// vertex normals
- (void)setCenterVertexHeight:(GLfloat)aValue
{
   centerVertexHeight = aValue;
   
   SceneVertex newVertexE = vertexE;
   newVertexE.position.z = self.centerVertexHeight;
   
   triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
   triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
   triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
   triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
   
   [self updateNormals];
}


/////////////////////////////////////////////////////////////////
// This method returns the value of shouldUseFaceNormals.
- (BOOL)shouldUseFaceNormals
{
   return shouldUseFaceNormals;
}


/////////////////////////////////////////////////////////////////
// This method sets the value of shouldUseFaceNormals and updates
// vertex normals if necessary
- (void)setShouldUseFaceNormals:(BOOL)aValue
{
   if(aValue != shouldUseFaceNormals)
   {
      shouldUseFaceNormals = aValue;
      
      [self updateNormals];
   }
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


/////////////////////////////////////////////////////////////////
// This function returns the face normal vector for triangle.
static GLKVector3 SceneTriangleFaceNormal(
   const SceneTriangle triangle)
{
   GLKVector3 vectorA = GLKVector3Subtract(
      triangle.vertices[1].position, 
      triangle.vertices[0].position);
   GLKVector3 vectorB = GLKVector3Subtract(
      triangle.vertices[2].position, 
      triangle.vertices[0].position);
      
   return SceneVector3UnitNormal(
      vectorA,
      vectorB);
}


/////////////////////////////////////////////////////////////////
// Calculates the face normal vectors for 8 triangles and then
// update the normal vectors for each vertex of each triangle 
// using the triangle's face normal for all three for the 
// triangle's vertices
static void SceneTrianglesUpdateFaceNormals(
   SceneTriangle someTriangles[NUM_FACES])
{
   int                i;
   
   for (i=0; i<NUM_FACES; i++)
   {
      GLKVector3 faceNormal = SceneTriangleFaceNormal(
         someTriangles[i]);
      someTriangles[i].vertices[0].normal = faceNormal;
      someTriangles[i].vertices[1].normal = faceNormal;
      someTriangles[i].vertices[2].normal = faceNormal;
   }
}


/////////////////////////////////////////////////////////////////
// This function calculates the face normal vectors for 8 
// triangles and then updates the normal vector for each vertex
// by averaging the face normal vectors of each triangle that 
// shares the vertex.
static void SceneTrianglesUpdateVertexNormals(
   SceneTriangle someTriangles[NUM_FACES])
{
   SceneVertex newVertexA = vertexA;
   SceneVertex newVertexB = vertexB;
   SceneVertex newVertexC = vertexC;
   SceneVertex newVertexD = vertexD;
   SceneVertex newVertexE = someTriangles[3].vertices[0];
   SceneVertex newVertexF = vertexF;
   SceneVertex newVertexG = vertexG;
   SceneVertex newVertexH = vertexH;
   SceneVertex newVertexI = vertexI;
   GLKVector3 faceNormals[NUM_FACES];
   
   // Calculate the face normal of each triangle
   for (int i=0; i<NUM_FACES; i++)
   {
      faceNormals[i] = SceneTriangleFaceNormal(
         someTriangles[i]);
   }
   
   // Average each of the vertex normals with the face normals of 
   // the 4 adjacent vertices
   newVertexA.normal = faceNormals[0];
   newVertexB.normal = GLKVector3MultiplyScalar(
      GLKVector3Add(
         GLKVector3Add(
            GLKVector3Add(
               faceNormals[0], 
               faceNormals[1]), 
            faceNormals[2]), 
         faceNormals[3]), 0.25);
   newVertexC.normal = faceNormals[1];
   newVertexD.normal = GLKVector3MultiplyScalar(
      GLKVector3Add(
         GLKVector3Add(
            GLKVector3Add(
               faceNormals[0], 
               faceNormals[2]), 
            faceNormals[4]), 
         faceNormals[6]), 0.25);
   newVertexE.normal = GLKVector3MultiplyScalar(
      GLKVector3Add(
         GLKVector3Add(
            GLKVector3Add(
               faceNormals[2], 
               faceNormals[3]), 
            faceNormals[4]), 
         faceNormals[5]), 0.25);
   newVertexF.normal = GLKVector3MultiplyScalar(
      GLKVector3Add(
         GLKVector3Add(
            GLKVector3Add(
               faceNormals[1], 
               faceNormals[3]), 
            faceNormals[5]), 
         faceNormals[7]), 0.25);
   newVertexG.normal = faceNormals[6];
   newVertexH.normal = GLKVector3MultiplyScalar(
      GLKVector3Add(
         GLKVector3Add(
            GLKVector3Add(
               faceNormals[4], 
               faceNormals[5]), 
            faceNormals[6]), 
         faceNormals[7]), 0.25);
   newVertexI.normal = faceNormals[7];
   
   // Recreate the triangles for the scene using the new
   // vertices that have recalculated normals
   someTriangles[0] = SceneTriangleMake(
      newVertexA, 
      newVertexB, 
      newVertexD);
   someTriangles[1] = SceneTriangleMake(
      newVertexB, 
      newVertexC, 
      newVertexF);
   someTriangles[2] = SceneTriangleMake(
      newVertexD, 
      newVertexB, 
      newVertexE);
   someTriangles[3] = SceneTriangleMake(
      newVertexE, 
      newVertexB, 
      newVertexF);
   someTriangles[4] = SceneTriangleMake(
      newVertexD, 
      newVertexE, 
      newVertexH);
   someTriangles[5] = SceneTriangleMake(
      newVertexE, 
      newVertexF, 
      newVertexH);
   someTriangles[6] = SceneTriangleMake(
      newVertexG, 
      newVertexD, 
      newVertexH);
   someTriangles[7] = SceneTriangleMake(
      newVertexH, 
      newVertexF, 
      newVertexI);
}


/////////////////////////////////////////////////////////////////
// This function initializes the values in someNormalLineVertices
// with vertices for lines that represent the normal vectors for 
// 8 triangles and a line that represents the light direction.
static  void SceneTrianglesNormalLinesUpdate(
   const SceneTriangle someTriangles[NUM_FACES],
   GLKVector3 lightPosition,
   GLKVector3 someNormalLineVertices[NUM_LINE_VERTS])
{
   int                       trianglesIndex;
   int                       lineVetexIndex = 0;
   
   // Define lines that indicate direction of each normal vector 
   for (trianglesIndex = 0; trianglesIndex < NUM_FACES;
      trianglesIndex++)
   {
      someNormalLineVertices[lineVetexIndex++] = 
         someTriangles[trianglesIndex].vertices[0].position;
      someNormalLineVertices[lineVetexIndex++] = 
         GLKVector3Add(
            someTriangles[trianglesIndex].vertices[0].position, 
            GLKVector3MultiplyScalar(
               someTriangles[trianglesIndex].vertices[0].normal, 
               0.5));
      someNormalLineVertices[lineVetexIndex++] = 
         someTriangles[trianglesIndex].vertices[1].position;
      someNormalLineVertices[lineVetexIndex++] = 
         GLKVector3Add(
            someTriangles[trianglesIndex].vertices[1].position, 
            GLKVector3MultiplyScalar(
               someTriangles[trianglesIndex].vertices[1].normal, 
               0.5));
      someNormalLineVertices[lineVetexIndex++] = 
         someTriangles[trianglesIndex].vertices[2].position;
      someNormalLineVertices[lineVetexIndex++] = 
         GLKVector3Add(
            someTriangles[trianglesIndex].vertices[2].position, 
            GLKVector3MultiplyScalar(
               someTriangles[trianglesIndex].vertices[2].normal, 
               0.5));
   }
   
   // Add a line to indicate light direction
   someNormalLineVertices[lineVetexIndex++] = 
      lightPosition;
      
   someNormalLineVertices[lineVetexIndex] = GLKVector3Make(
      0.0, 
      0.0, 
      -0.5);
}


#pragma mark - Utility GLKVector3 functions

/////////////////////////////////////////////////////////////////
// Returns a unit vector in the same direction as the cross 
// product of vectorA and VectorB
GLKVector3 SceneVector3UnitNormal(
   const GLKVector3 vectorA, 
   const GLKVector3 vectorB)
{
   return GLKVector3Normalize(
      GLKVector3CrossProduct(vectorA, vectorB));
}
