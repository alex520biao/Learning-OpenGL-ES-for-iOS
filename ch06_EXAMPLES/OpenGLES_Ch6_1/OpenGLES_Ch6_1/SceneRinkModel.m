//
//  SceneRinkModel.m
//  OpenGLES_Ch6_1
//

#import "SceneRinkModel.h"
#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "bumperRink.h"


@implementation SceneRinkModel

/////////////////////////////////////////////////////////////////
// Initialize the receiver's properties with data from the 
// bumperRink.h file.
- (id)init
{
   SceneMesh *rinkMesh = [[SceneMesh alloc] 
      initWithPositionCoords:bumperRinkVerts
      normalCoords:bumperRinkNormals
      texCoords0:NULL
      numberOfPositions:bumperRinkNumVerts
      indices:NULL
      numberOfIndices:0];

   if(nil != (self = [super initWithName:@"bumberRink"
      mesh:rinkMesh
      numberOfVertices:bumperRinkNumVerts]))
   {
      [self updateAlignedBoundingBoxForVertices:bumperRinkVerts
         count:bumperRinkNumVerts];
   }

   return self;
}

@end
