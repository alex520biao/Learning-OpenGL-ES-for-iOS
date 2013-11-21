//
//  UtilityOpenGLCamera.h
//  
//

#include <OpenGL/gl.h>
#import "UtilityVector.h"
#import "UtilityFrustum.h"


@interface UtilityOpenGLCamera : NSObject 
{
	UtilityVector3    lookAtPosition;  /*" "*/
	UtilityVector3    upVector;        /*" "*/
  GLfloat          fieldOfViewDeg;  /*" "*/
  GLfloat          maxDistanceFromLookAtPosition;
  GLfloat          minDistanceFromLookAtPosition;
  GLfloat          maxCameraElevation;
  GLfloat          top;
  GLfloat          bottom;
  GLfloat          left;
  GLfloat          right;
  UtilityFrustum     frustum;
  BOOL             isInitialized;
  BOOL				  hasLandscapeOrientation;
}

@property (nonatomic, assign, readonly) BOOL isInitialized;
@property (nonatomic, assign, readwrite) BOOL hasLandscapeOrientation;
@property (nonatomic, assign, readwrite) __unsafe_unretained IBOutlet id delegate;
@property (nonatomic, assign, readonly) UtilityVector3 upVector;

- (void)configurePerspectiveProjectionWithAspectRatio:(GLfloat)aspectRatio;
- (void)configureModelView;

- (const UtilityFrustum *)frustum;

- (UtilityVector3)position;
- (void)setPositionX:(float)x y:(float)y z:(float)z;
- (void)setPosition:(UtilityVector3)aVector;
- (UtilityVector3)lookAtPosition;
- (void)setLookAtPosition:(UtilityVector3)aVector;

- (void)panDeltaRight:(GLfloat)aDeltaRight deltaUp:(GLfloat)aDeltaUp;
- (void)rotateAngleRadiansAboutY:(GLfloat)anAngleRadians;

- (void)recalcInternalStateWithPosition:(UtilityVector3)aPosition 
                         lookAtPosition:(UtilityVector3)aLookAtPosition 
                     distanceConstraint:(float)aDistanceConstraint;

- (float)distanceFromLookAtPosition;
- (void)setDistanceFromLookAtPosition:(float)distance;
- (void)setMinDistanceFromLookAtPosition:(float)distance;
- (void)setMaxDistanceFromLookAtPosition:(float)distance;
- (void)setMaxCameraElevation:(float)anElevation;
- (float)maxCameraElevation;

- (void)setFieldOfViewDeg:(float)degrees;

- (void)cameraPositionDidChange:(id)sender;

@end
