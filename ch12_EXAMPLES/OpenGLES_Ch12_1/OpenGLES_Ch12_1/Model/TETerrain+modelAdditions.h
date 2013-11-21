//
//  TETerrain+modelAdditions.h
//  OpenGLES_Ch12_1
//

#import "TETerrain.h"
#import <GLKit/GLKit.h>


@interface TETerrain (modelAdditions)

- (GLfloat)calculatedHeightAtXPosMeters:(GLfloat)x 
   zPosMeters:(GLfloat)z
   surfaceNormal:(GLKVector3 *)aNormal;
- (GLfloat)calculatedHeightAtXPos:(GLfloat)x 
   zPos:(GLfloat)z
   surfaceNormal:(GLKVector3 *)aNormal;
- (GLfloat)heightAtXPos:(NSInteger)x zPos:(NSInteger)z;
- (GLfloat)heightAtXPosMeters:(GLfloat)x zPosMeters:(GLfloat)z;
- (GLfloat)maxHeightNearXPosMeters:(NSInteger)x 
   zPosMeters:(NSInteger)z;
- (GLfloat)regionalHeightAtXPosMeters:(NSInteger)x 
   zPosMeters:(NSInteger)z;
- (BOOL)isHeightValidAtXPos:(NSInteger)x zPos:(NSInteger)z;
- (BOOL)isHeightValidAtXPosMeters:(NSInteger)x 
   zPosMeters:(NSInteger)z;

- (GLfloat)widthMeters;
- (GLfloat)heightMeters;
- (GLfloat)lengthMeters;

@end
