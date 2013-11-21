//
//  SceneAnimatedMesh.h
//
//

#import "SceneMesh.h"


@interface SceneAnimatedMesh : SceneMesh

- (void)drawEntireMesh;
- (void)updateMeshWithDefaultPositions;
- (void)updateMeshWithElapsedTime:(NSTimeInterval)anInterval;
   
@end
