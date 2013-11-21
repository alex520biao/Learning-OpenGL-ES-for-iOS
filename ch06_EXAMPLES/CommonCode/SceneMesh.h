//
//  SceneMesh.h
//  
//

#import <GLKit/GLKit.h>

/////////////////////////////////////////////////////////////////
// Type used to store vertex attributes
typedef struct
{
   GLKVector3 position;
   GLKVector3 normal;
   GLKVector2 texCoords0;
}
SceneMeshVertex;


@interface SceneMesh : NSObject

- (id)initWithVertexAttributeData:(NSData *)vertexAttributes
   indexData:(NSData *)indices;

- (id)initWithPositionCoords:(const GLfloat *)somePositions
   normalCoords:(const GLfloat *)someNormals
   texCoords0:(const GLfloat *)someTexCoords0
   numberOfPositions:(size_t)countPositions
   indices:(const GLushort *)someIndices
   numberOfIndices:(size_t)countIndices;
   
- (void)prepareToDraw;

- (void)drawUnidexedWithMode:(GLenum)mode
   startVertexIndex:(GLint)first
   numberOfVertices:(GLsizei)count;

- (void)makeDynamicAndUpdateWithVertices:
   (const SceneMeshVertex *)someVerts
   numberOfVertices:(size_t)count;

@end
