//
//  CVMesh.h
//  COLLADAViewer
//

#import <Foundation/Foundation.h>
#include "UtilityVector.h"
#include "UtilityMatrix.h"


/////////////////////////////////////////////////////////////////
//  
typedef struct
{
   UtilityVector3 position;
   UtilityVector3 normal;
   UtilityVector2 texCoords0;
   UtilityVector2 texCoords1;
}
CVMeshVertex;


@interface CVMesh : NSObject

@property (retain, nonatomic, readonly) NSData
   *vertexData;
@property (retain, nonatomic, readonly) NSData
   *indexData;
@property (assign, nonatomic, readonly) NSUInteger
   numberOfIndices;
@property (retain, nonatomic, readonly) NSArray
   *commands;
@property (retain, nonatomic, readonly) NSDictionary
   *plistRepresentation;
@property (copy, nonatomic, readonly) NSString
   *axisAlignedBoundingBoxString;

- (id)initWithPlistRepresentation:(NSDictionary *)aDictionary;

- (id)appendVertexData:(NSData *)someVertexData
   indexData:(NSData *)someIndexData;

- (CVMeshVertex)vertexAtIndex:(NSUInteger)anIndex;
- (void)setVertex:(CVMeshVertex)aVertex 
   atIndex:(NSUInteger)anIndex;
- (void)appendVertex:(CVMeshVertex)aVertex;

- (GLushort)indexAtIndex:(NSUInteger)anIndex;
- (void)appendIndex:(GLushort)index;

- (void)appendCommand:(GLenum)command 
   firstIndex:(size_t)firstIndex
   numberOfIndices:(size_t)numberOfIndices
   materialName:(NSString *)materialName;

- (void)appendMesh:(CVMesh *)aMesh;

- (id)copyWithTransform:(UtilityMatrix4)transforms;

- (void)prepareToDraw;
- (void)drawAllCommands;
- (void)drawNormalsAllCommandsLength:(GLfloat)linelength;
- (void)drawCommandsInRange:(NSRange)aRange;
- (void)drawNormalsCommandsInRange:(NSRange)aRange
   length:(GLfloat)lineLength;

- (NSUInteger)numberOfVerticesForCommandsInRange:(NSRange)aRange;

- (NSString *)axisAlignedBoundingBoxStringForCommandsInRange:
   (NSRange)aRange;
   
@end
