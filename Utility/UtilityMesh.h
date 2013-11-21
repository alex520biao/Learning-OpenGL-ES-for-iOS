//
//  UtilityMesh.h
//  
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

/////////////////////////////////////////////////////////////////
// Type used to store mesh vertex attribues
typedef struct
{
   GLKVector3 position;
   GLKVector3 normal;
   GLKVector2 texCoords0;
   GLKVector2 texCoords1;
}
UtilityMeshVertex;


@interface UtilityMesh : NSObject
{
   GLuint indexBufferID_;
   GLuint vertexBufferID_;
   GLuint vertexExtraBufferID_;
   GLuint vertexArrayID_;
}

@property (strong, nonatomic, readonly) NSData
   *vertexData;
@property (strong, nonatomic, readonly) NSData
   *indexData;
@property (strong, nonatomic, readonly) NSMutableData
   *extraVertexData;
@property (assign, nonatomic, readonly) NSUInteger
   numberOfIndices;
@property (strong, nonatomic, readonly) NSArray
   *commands;
@property (strong, nonatomic, readonly) NSDictionary
   *plistRepresentation;
@property (copy, nonatomic, readonly) NSString
   *axisAlignedBoundingBoxString;
@property (assign, nonatomic, readwrite) BOOL
   shouldUseVAOExtension;

- (id)initWithPlistRepresentation:(NSDictionary *)aDictionary;

- (UtilityMeshVertex)vertexAtIndex:(NSUInteger)anIndex;
- (GLushort)indexAtIndex:(NSUInteger)anIndex;

- (NSString *)axisAlignedBoundingBoxStringForCommandsInRange:
   (NSRange)aRange;
   
@end

/////////////////////////////////////////////////////////////////
// Constants used to access properties from a drawing
// command dictionary.
NSString *const UtilityMeshCommandNumberOfIndices;
NSString *const UtilityMeshCommandFirstIndex;
