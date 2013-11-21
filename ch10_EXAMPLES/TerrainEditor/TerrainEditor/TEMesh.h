//
//  TEMesh.h
//  TerrainEditor
//

#import <Foundation/Foundation.h>
#import "UtilityMatrix.h"

/////////////////////////////////////////////////////////////////
//  
typedef struct
{
   UtilityVector3 position;
   UtilityVector3 normal;
   UtilityVector2 texCoords0;
   UtilityVector2 texCoords1;
}
TEMeshVertex;


@interface TEMesh : NSObject

@property (strong, nonatomic, readonly) NSData
   *vertexData;
@property (strong, nonatomic, readonly) NSData
   *indexData;
@property (assign, nonatomic, readonly) NSUInteger
   numberOfIndices;
@property (strong, nonatomic, readonly) NSArray
   *commands;
@property (strong, nonatomic, readonly) NSDictionary
   *plistRepresentation;
@property (copy, nonatomic, readonly) NSString
   *axisAlignedBoundingBoxString;

- (id)initWithPlistRepresentation:(NSDictionary *)aDictionary;

- (id)appendVertexData:(NSData *)someVertexData
   indexData:(NSData *)someIndexData;

- (TEMeshVertex)vertexAtIndex:(NSUInteger)anIndex;
- (void)setVertex:(TEMeshVertex)aVertex 
   atIndex:(NSUInteger)anIndex;
- (void)appendVertex:(TEMeshVertex)aVertex;

- (GLushort)indexAtIndex:(NSUInteger)anIndex;
- (void)appendIndex:(GLushort)index;

- (void)appendCommand:(GLenum)command 
   firstIndex:(size_t)firstIndex
   numberOfIndices:(size_t)numberOfIndices
   materialName:(NSString *)materialName;

- (void)appendMesh:(TEMesh *)aMesh;

- (id)copyWithTransform:(UtilityMatrix4)transforms;

- (void)prepareToDraw;
- (void)prepareToPick;
- (void)drawCommandsInRange:(NSRange)aRange;
- (void)drawBoundingBoxStringForCommandsInRange:
   (NSRange)aRange;

- (NSString *)axisAlignedBoundingBoxStringForCommandsInRange:
   (NSRange)aRange;
   
@end
