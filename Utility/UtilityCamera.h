//
//  UtilityOpenGLCamera.h
//  
//

#include <GLKit/GLKit.h>
#import "AGLKFrustum.h"

@class UtilityCamera; 

@protocol UtilityOpenGLCameraDelegate <NSObject>

/////////////////////////////////////////////////////////////////
// Returning NO prevents changes.
@optional
- (BOOL)camera:(UtilityCamera *)aCamera
   willChangeEyePosition:(GLKVector3 *)eyePositionPtr
   lookAtPosition:(GLKVector3 *)lookAtPositionPtr;

@end


@interface UtilityCamera : NSObject

@property (nonatomic, assign, readwrite) 
   __unsafe_unretained IBOutlet id delegate;
@property(assign, nonatomic, readonly) 
   GLKMatrix4 projectionMatrix;
@property(assign, nonatomic, readonly) 
   GLKMatrix4 modelviewMatrix;
@property(assign, nonatomic, readonly) 
   GLKVector3 position;
@property(assign, nonatomic, readonly) 
   GLKVector3 lookAtPosition;
@property(assign, nonatomic, readonly) 
   GLKVector3 upUnitVector;
@property(nonatomic, readonly) 
   const AGLKFrustum *frustumForCulling;

- (void)configurePerspectiveFieldOfViewRad:(GLfloat)angle
   aspectRatio:(GLfloat)anAspectRatio
   near:(GLfloat)nearLimit
   far:(GLfloat)farLimit;

- (void)rotateAngleRadiansAboutY:(GLfloat)anAngleRadians;
- (void)rotateAngleRadiansAboutX:(GLfloat)anAngleRadians;

- (void)moveBy:(GLKVector3)aVector;
- (void)moveTo:(GLKVector3)aVector;

- (void)setPosition:(GLKVector3)aPosition 
   lookAtPosition:(GLKVector3)lookAtPosition;
- (void)setOrientation:(GLKMatrix4)aMatrix;

@end
