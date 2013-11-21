//
//  SceneCarModel.m
//  OpenGLES_Ch6_1
//

#import "SceneCarModel.h"
#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "bumperCar.h"


@implementation SceneCarModel

/////////////////////////////////////////////////////////////////
// Initialize the receiver's properties with data from the 
// bumperCar.h file.
- (id)init
{
   SceneMesh *carMesh = [[SceneMesh alloc] 
      initWithPositionCoords:bumperCarVerts
      normalCoords:bumperCarNormals
      texCoords0:NULL
      numberOfPositions:bumperCarNumVerts
      indices:NULL
      numberOfIndices:0];

   if(nil != (self = [super initWithName:@"bumberCar"
      mesh:carMesh
      numberOfVertices:bumperCarNumVerts]))
   {
      [self updateAlignedBoundingBoxForVertices:bumperCarVerts
         count:bumperCarNumVerts];
   }

   return self;
}

@end
