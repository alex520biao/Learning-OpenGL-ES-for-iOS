//
//  SceneMesh.m
//  
//

#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"


@interface SceneMesh ()

@property (strong, nonatomic, readwrite) 
   AGLKVertexAttribArrayBuffer *vertexAttributeBuffer;
@property (assign, nonatomic, readwrite) GLuint 
   indexBufferID;
@property (strong, nonatomic, readwrite) NSData
   *vertexData;
@property (strong, nonatomic, readwrite) NSData
   *indexData;
 
@end


@implementation SceneMesh

@synthesize vertexAttributeBuffer;
@synthesize indexBufferID;
@synthesize vertexData;
@synthesize indexData;


/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)initWithVertexAttributeData:(NSData *)vertexAttributes
   indexData:(NSData *)indices;
{
   if(nil != (self=[super init]))
   {
      self.vertexData = vertexAttributes;
      self.indexData = indices;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// Initialize a new instance with the specifies sources of
// vertex attributes and element indices. The somePositions
// and someNormals must both be valid pointers to at least
// countPositions number of coordinates where each coordinate
// has size (3 * GLfloat). If not NULL, someTexCoords0 must be
// a valid pointer to countPositions of coordinates where each 
// coordinate has size (2 * GLfloat). If not NULL, someIndices
// must be a valid pointer to countIndices vertex indices where
// each index has size (1 * GLushort).
// Note: This method is intended for initializing a mesh from
// declarations produced by the obj2opengl.pl tool.
- (id)initWithPositionCoords:(const GLfloat *)somePositions
   normalCoords:(const GLfloat *)someNormals
   texCoords0:(const GLfloat *)someTexCoords0
   numberOfPositions:(size_t)countPositions
   indices:(const GLushort *)someIndices
   numberOfIndices:(size_t)countIndices;
{
   NSParameterAssert(NULL != somePositions);
   NSParameterAssert(NULL != someNormals);
   NSParameterAssert(0 < countPositions);
   
   NSMutableData *vertexAttributesData = 
      [[NSMutableData alloc] init];
   NSMutableData *indicesData = 
      [[NSMutableData alloc] init];
   
   // Accumulate indices into indicesData
   [indicesData appendBytes:someIndices 
      length:countIndices * sizeof(GLushort)];

   // Accumulate vertex attributes into vertexAttributesData
   for(size_t i = 0; i < countPositions; i++)
   {
      SceneMeshVertex currentVertex;
      
      // Initialize the position coordinates
      currentVertex.position.x = somePositions[i * 3 + 0];
      currentVertex.position.y = somePositions[i * 3 + 1];
      currentVertex.position.z = somePositions[i * 3 + 2];

      // Initialize the normal coordinates if there are any
      currentVertex.normal.x = someNormals[i * 3 + 0];
      currentVertex.normal.y = someNormals[i * 3 + 1];
      currentVertex.normal.z = someNormals[i * 3 + 2];

      // Initialize the texture coordinates if there are any
      if(NULL != someTexCoords0)
      {
         currentVertex.texCoords0.s = someTexCoords0[i * 2 + 0];
         currentVertex.texCoords0.t = someTexCoords0[i * 2 + 1];
      }
      else
      {
         currentVertex.texCoords0.s = 0.0f;
         currentVertex.texCoords0.t = 0.0f;
      }
      
      // Append the vertex attributes to data
      [vertexAttributesData appendBytes:&currentVertex 
         length:sizeof(currentVertex)];
   }
   
   return [self initWithVertexAttributeData:vertexAttributesData
      indexData:indicesData];
}


/////////////////////////////////////////////////////////////////
// Cleanup resources
- (void)dealloc
{
   if(0 != indexBufferID)
   {
      glDeleteBuffers(1, &indexBufferID);
      indexBufferID = 0;
   }
}


/////////////////////////////////////////////////////////////////
// This method prepares the current OpenGL ES 2.0 context for
// drawing with the receiver's vertex attributes and indices.
- (void)prepareToDraw;
{
   if(nil == self.vertexAttributeBuffer && 
      0 < [self.vertexData length])
   {  // vertex attiributes haven't been sent to GPU yet
      self.vertexAttributeBuffer = 
         [[AGLKVertexAttribArrayBuffer alloc]
         initWithAttribStride:sizeof(SceneMeshVertex)
         numberOfVertices:[self.vertexData length] / 
            sizeof(SceneMeshVertex) 
         data:[self.vertexData bytes]
         usage:GL_STATIC_DRAW];
      
      // No longer need local data storage
      self.vertexData = nil;
   }
   
   if(0 == indexBufferID && 0 < [self.indexData length])
   {  // Indices haven't been sent to GPU yet
      // Create an element array buffer for mesh indices
      glGenBuffers(1, &indexBufferID);
      NSAssert(0 != self.indexBufferID, 
         @"Failed to generate element array buffer");
          
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferID);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, 
         [self.indexData length], 
         [self.indexData bytes], 
         GL_STATIC_DRAW);
      
      // No longer need local index storage
      self.indexData = nil;
   }
   
   // Prepare vertex buffer for drawing
   [self.vertexAttributeBuffer 
      prepareToDrawWithAttrib:GLKVertexAttribPosition
      numberOfCoordinates:3
      attribOffset:offsetof(SceneMeshVertex, position)
      shouldEnable:YES];
      
   [self.vertexAttributeBuffer 
      prepareToDrawWithAttrib:GLKVertexAttribNormal
      numberOfCoordinates:3
      attribOffset:offsetof(SceneMeshVertex, normal)
      shouldEnable:YES];

   [self.vertexAttributeBuffer 
      prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
      numberOfCoordinates:2
      attribOffset:offsetof(SceneMeshVertex, texCoords0)
      shouldEnable:YES];

   // Bind the element array buffer (indices)
   glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
}


/////////////////////////////////////////////////////////////////
// Draw the entire mesh after it has been prepared for drawing.
// This method does not use vertex element indexing. Vertices
// in the range first to (first+count-1) are drawn in order
// using mode.
- (void)drawUnidexedWithMode:(GLenum)mode
   startVertexIndex:(GLint)first
   numberOfVertices:(GLsizei)count;
{
   [self.vertexAttributeBuffer drawArrayWithMode:mode
      startVertexIndex:first
      numberOfVertices:count];
}


/////////////////////////////////////////////////////////////////
// This method sends count sets of vertex attributes read from
// someVerts to the GPU. This method also marks the resulting
// vertex attribute array as a dynamic array prone to frequent
// updates.
- (void)makeDynamicAndUpdateWithVertices:
   (const SceneMeshVertex *)someVerts
   numberOfVertices:(size_t)count;
{
   NSParameterAssert(NULL != someVerts);
   NSParameterAssert(0 < count);
   
   if(nil == self.vertexAttributeBuffer)
   {  // vertex attiributes haven't been sent to GPU yet
      self.vertexAttributeBuffer = 
         [[AGLKVertexAttribArrayBuffer alloc]
         initWithAttribStride:sizeof(SceneMeshVertex)
         numberOfVertices:count 
         data:someVerts
         usage:GL_DYNAMIC_DRAW];
   }
   else
   {
      [self.vertexAttributeBuffer 
         reinitWithAttribStride:sizeof(SceneMeshVertex)
         numberOfVertices:count
         data:someVerts];
   }
}


@end
