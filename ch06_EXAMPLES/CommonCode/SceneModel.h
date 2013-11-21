//
//  SceneModel.h
//  
//

#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;
@class SceneMesh;


/////////////////////////////////////////////////////////////////
// Type that defines the bounding box for a model. No vertex
// position in the model has position.x less than min.x or 
// position.x greater than max.x. The same is true for Y and Z
// coordinates.
typedef struct
{
   GLKVector3 min;
   GLKVector3 max;
}
SceneAxisAllignedBoundingBox;


@interface SceneModel : NSObject

@property (copy, nonatomic, readonly) NSString
   *name;
@property (assign, nonatomic, readonly) 
   SceneAxisAllignedBoundingBox axisAlignedBoundingBox;


- (id)initWithName:(NSString *)aName
   mesh:(SceneMesh *)aMesh
   numberOfVertices:(GLsizei)aCount;
   
- (void)draw;

- (void)updateAlignedBoundingBoxForVertices:(float *)verts
   count:(unsigned int)aCount;

@end
