//
//  UtilityOpenGLCamera.h
//  
//

#include <OpenGL/gl.h>
#import "UtilityVector.h"
#import "UtilityFrustum.h"
#import "UtilityMatrix.h"


@interface UtilityOpenGLCamera : NSObject 

@property (nonatomic, assign, readwrite) __unsafe_unretained IBOutlet id delegate;
@property (nonatomic, assign, readonly) BOOL isInitialized;
@property(assign, nonatomic, readonly) UtilityMatrix4 projectionMatrix;
@property(assign, nonatomic, readonly) UtilityMatrix4 modelviewMatrix;
@property(assign, nonatomic, readwrite) UtilityVector3 position;
@property(assign, nonatomic, readwrite) UtilityVector3 lookAtPosition;
@property (nonatomic, assign, readonly) UtilityVector3 upVector;
@property (nonatomic, assign, readonly) UtilityVector3 forwardVector;
@property (nonatomic, assign, readonly) UtilityVector3 rightVector;
@property(assign, nonatomic, readwrite) GLfloat distanceFromLookAtPosition;
@property(assign, nonatomic, readwrite) GLfloat fieldOfViewDeg;

- (void)configurePerspectiveProjectionWithAspectRatio:(GLfloat)aspectRatio;

- (const UtilityFrustum *)frustum;

- (void)panDeltaForward:(GLfloat)aDelta;
- (void)panDeltaRight:(GLfloat)aDeltaRight deltaUp:(GLfloat)aDeltaUp;
- (void)rotateAngleRadiansAboutY:(GLfloat)anAngleRadians;

// Delegate method
- (void)cameraPositionDidChange:(UtilityOpenGLCamera *)sender;

@end
