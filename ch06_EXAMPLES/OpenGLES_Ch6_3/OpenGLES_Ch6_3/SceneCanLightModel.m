//
//  SceneCanLightModel.m
// 
//

#import "SceneCanLightModel.h"
#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "canLight.h"


@implementation SceneCanLightModel

/////////////////////////////////////////////////////////////////
// Initialize the receiver's properties with data from the 
// SceneCanLightModel.h file.
- (id)init
{
   SceneMesh *canLightMesh = [[SceneMesh alloc] 
      initWithPositionCoords:canLightVerts
      normalCoords:canLightNormals
      texCoords0:NULL
      numberOfPositions:canLightNumVerts
      indices:NULL
      numberOfIndices:0];

   if(nil != (self = [super initWithName:@"canLight"
      mesh:canLightMesh
      numberOfVertices:canLightNumVerts]))
   {
      [self updateAlignedBoundingBoxForVertices:canLightVerts
         count:canLightNumVerts];
   }

   return self;
}

@end
