//
//  UtilityOpenGLCamera.m
//  
//

#import "UtilityOpenGLCamera.h"
#import "UtilityMath.h"
#include <OpenGL/glu.h>

#define UtilityCameraFarPlaneRatio (1.5f)
#define UtilityCameraMaxFieldOfViewDeg (175.0f)
#define UtilityCameraMinFieldOfViewDeg (1.0f)


/////////////////////////////////////////////////////////////////
//
@interface UtilityOpenGLCamera ()

@property (nonatomic, assign, readwrite) BOOL isInitialized;

@end


/////////////////////////////////////////////////////////////////
//
@implementation UtilityOpenGLCamera

static const float _UtilityDefaultMaxZoom = (6.0f);
static const float _UtilityDefaultMinZoom = (0.1f);
static const UtilityVector3 _UtilityDefaultLookAtPosition = 
   {0.0f, 0.0f, 0.0f};   
static const UtilityVector3 _UtilityDefaultUpVector = 
   {0.0f, 1.0f, 0.0f};   
static const UtilityVector3 _UtilityDefaultPosition = 
   {7.0f, 7.0f, 7.0f};   
static const float _UtilityDefaultFieldOfViewDeg = 45.0f;
static const float _UtilityDefaultAspectRatio = 1.0f;
static const float _UtilityDefaultMaxDistanceFromLookAtPosition = 
   3000.0f;
static const float _UtilityDefaultMinDistanceFromLookAtPosition = 
   0.2f;
static const float _UtilityDefaultMaxCameraElevation = 40.0f;
static const float _UtilityDefaultMinDistance = 0.2f;
static const float _UtilityDefaultNearDistance = 0.1f *
   _UtilityDefaultMinDistanceFromLookAtPosition;
static const float _UtilityDefaultFarDistance = 2.0f * 
   _UtilityDefaultMaxDistanceFromLookAtPosition;

@synthesize isInitialized;
@synthesize hasLandscapeOrientation;
@synthesize delegate;
@synthesize upVector;


/////////////////////////////////////////////////////////////////
//
- (id)init
{
   self = [super init];
   if(nil != self)
   {
      lookAtPosition = _UtilityDefaultLookAtPosition;   
      upVector = _UtilityDefaultUpVector;        
      frustum.cameraPosition = _UtilityDefaultPosition;        
      
      fieldOfViewDeg = _UtilityDefaultFieldOfViewDeg;
      frustum.aspectRatio = _UtilityDefaultAspectRatio;
      frustum.nearDistance = _UtilityDefaultNearDistance;
      frustum.farDistance = _UtilityDefaultFarDistance;
      maxDistanceFromLookAtPosition = 
         MAX(minDistanceFromLookAtPosition, 
         _UtilityDefaultMaxDistanceFromLookAtPosition);
      minDistanceFromLookAtPosition = 
         _UtilityDefaultMinDistanceFromLookAtPosition;
      maxCameraElevation = _UtilityDefaultMaxCameraElevation;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//
- (void)configurePerspectiveProjectionWithAspectRatio:
   (GLfloat)anAspectRatio
{  // This method MUST be called before camera can be used and 
   // again every time the display aspect ratio changes such as 
   // when the window is resized
   UtilityVector3 cameraPosition = frustum.cameraPosition;
   frustum = UtilityFrustumWithCameraParameters
   (
    fieldOfViewDeg, 
    anAspectRatio, 
    MAX(_UtilityDefaultMinDistance, 
       MIN(_UtilityDefaultNearDistance, 0.5f * 
          frustum.nearDistance)), 
    frustum.farDistance);
   
   if([self hasLandscapeOrientation])
   {
      UtilityVector3 landscapeUpvector = UtilityVector3Make
      (upVector.y, upVector.x, upVector.z);
      
      UtilityFrustumSetPositionAndDirection
      (&frustum, cameraPosition, lookAtPosition, 
         landscapeUpvector);
   }
   else
   {
      UtilityFrustumSetPositionAndDirection
      (&frustum, cameraPosition, lookAtPosition, upVector);
   }
   
   {
      top = frustum.nearDistance * tan
      (UtilityDegreesToRadians * fieldOfViewDeg / 2.0f);
      bottom = -top;
      right = frustum.aspectRatio * top;
      left = -right;
      glFrustum(left, right, bottom, top, frustum.nearDistance, 
                frustum.farDistance);
   }
   
   
   self.isInitialized = YES;
}


/////////////////////////////////////////////////////////////////
//
- (void)configureModelView
{  // Called every frame even if camera hasn't moved
   gluLookAt(frustum.cameraPosition.x, 
      frustum.cameraPosition.y, 
      frustum.cameraPosition.z,  
      lookAtPosition.x, 
      lookAtPosition.y, 
      lookAtPosition.z, 
      upVector.x, 
      upVector.y, 
      upVector.z);
}


/////////////////////////////////////////////////////////////////
//
- (void)setPosition:(UtilityVector3)aPosition
{  // Primitive method for camera position movement
   frustum.cameraPosition = aPosition;
   
   [self cameraPositionDidChange:self];
}


/////////////////////////////////////////////////////////////////
//
- (void)setPositionX:(float)x y:(float)y z:(float)z
{  
   [self setPosition:UtilityVector3Make(x, y, z)];
}


/////////////////////////////////////////////////////////////////
//
- (UtilityVector3)position
{
   return frustum.cameraPosition;
}


/////////////////////////////////////////////////////////////////
//
- (const UtilityFrustum *)frustum
{
   NSAssert(self.isInitialized, 
      @"-frustum received before camera initialized");
   
   return &frustum;
}


/////////////////////////////////////////////////////////////////
//
- (UtilityVector3)lookAtPosition
{
   return lookAtPosition;
}


/////////////////////////////////////////////////////////////////
//
- (void)setLookAtPosition:(UtilityVector3)aVector
{  // Primitive method for camera look at position movement
   lookAtPosition = aVector;
}


/////////////////////////////////////////////////////////////////
//
- (void)moveBy:(UtilityVector3)aVector
{
   [self setLookAtPosition:UtilityVector3Add(
      [self lookAtPosition], aVector)]; 
   [self setPosition:UtilityVector3Add(
      [self position], aVector)]; 
}


/////////////////////////////////////////////////////////////////
//
- (void)panDeltaRight:(GLfloat)aDeltaRight 
   deltaUp:(GLfloat)aDeltaUp;
{  
	// compute the Z axis of the camera referential.  this axis 
   // points in the same direction from the looking direction
	UtilityVector3   zNormalVector = 
   UtilityVector3Normalize
   (
    UtilityVector3FromPositionToPosition(frustum.cameraPosition, 
                                         lookAtPosition));
   
	// X axis of camera with given "up" vector and Z axis
	UtilityVector3   xNormalVector = 
   UtilityVector3Normalize(
      UtilityVector3CrossProduct(zNormalVector, upVector));
   
   UtilityVector3   panXVector = UtilityVector3Scale
   (xNormalVector, aDeltaRight * right);
   UtilityVector3   panYVector = UtilityVector3Scale(upVector, 
      aDeltaUp * top);
   UtilityVector3   panZVector = UtilityVector3Scale
   (zNormalVector, aDeltaUp * top);
   UtilityVector3   moveVector = UtilityVector3Add
   (panXVector, 
    UtilityVector3Add(panYVector, panZVector));
   
   [self moveBy:moveVector];
}


/////////////////////////////////////////////////////////////////
//
- (void)rotateAngleRadiansAboutY:(GLfloat)anAngleRadians
{
   anAngleRadians = fmod(anAngleRadians, Utility2PI);
   
   //NSLog(@"angleDegreesAboutY = %f", UtilityRadiansToDegrees * 
   //  anAngleRadians);
   UtilityVector3      newPosition = [self position];
   UtilityVector3      currentLookAtPosition = 
      [self lookAtPosition];
   UtilityVector3      deltaVector = 
      UtilityVector3FromPositionToPosition(currentLookAtPosition, 
         newPosition);
   UtilityVector3      deltaVectorXZ = UtilityVector3Make(
      deltaVector.x, 0.0f, deltaVector.z);
   GLfloat          distanceXZ = UtilityVector3Length(
      deltaVectorXZ);
   
   newPosition.z = currentLookAtPosition.z + 
      sin(anAngleRadians) * distanceXZ;
   newPosition.x = currentLookAtPosition.x + 
      cos(anAngleRadians) * distanceXZ;
   
   //NSLog(@"newPosition = {%f, %f, %f}", 
   //  newPosition.x, newPosition.y, newPosition.z);
   [self setPosition:newPosition];
   //NSLog(@"distance = %f", [self distanceFromLookAtPosition]);
}


/////////////////////////////////////////////////////////////////
//
- (void)recalcInternalStateWithPosition:(UtilityVector3)aPosition 
   lookAtPosition:(UtilityVector3)aLookAtPosition 
   distanceConstraint:(float)aDistanceConstraint
{
   [self setPosition:aPosition];
   [self setDistanceFromLookAtPosition:UtilityVector3Length(
     UtilityVector3FromPositionToPosition(aPosition, 
        aLookAtPosition))];
   [self setLookAtPosition:aLookAtPosition];
}


/////////////////////////////////////////////////////////////////
//
- (float)distanceFromLookAtPosition
{
   UtilityVector3   curentLookAtPosition = [self lookAtPosition];
   UtilityVector3   currentPosition = [self position];
   
   return UtilityVector3Length(
      UtilityVector3FromPositionToPosition(
         currentPosition, curentLookAtPosition));
}


/////////////////////////////////////////////////////////////////
//
- (void)setDistanceFromLookAtPosition:(float)distance
{
   // calculate fractionalDistance in range 0 to 
   // maxDistanceFromLookAtPosition
   distance = MIN(distance, maxDistanceFromLookAtPosition);
   distance = MAX(distance, minDistanceFromLookAtPosition);
   
   // Calculate unit vector direction from position to 
   // lookAtPosition
   UtilityVector3   curentLookAtPosition = [self lookAtPosition];
   UtilityVector3   currentPosition = [self position];
   UtilityVector3   direction = UtilityVector3Normalize(
    UtilityVector3FromPositionToPosition(curentLookAtPosition, 
       currentPosition));
   
   // Calculate new position
   UtilityVector3   newPosition = UtilityVector3Add(
      UtilityVector3Scale(direction, distance), 
         curentLookAtPosition);
   
   //NSLog(@"newPosition = {%f, %f, %f}", newPosition.x, 
   //   newPosition.y, 
   //   newPosition.z);
   //NSLog(@"distance = %f", distance);
   [self setPosition:newPosition];
}


/////////////////////////////////////////////////////////////////
//
- (float)maxFieldOfViewDeg
{
   return UtilityCameraMaxFieldOfViewDeg;
}


/////////////////////////////////////////////////////////////////
//
- (float)minFieldOfViewDeg
{
   return UtilityCameraMinFieldOfViewDeg;
}


/////////////////////////////////////////////////////////////////
//
- (void)setFieldOfViewDeg:(float)degrees
{
   fieldOfViewDeg = MIN([self maxFieldOfViewDeg], 
                        MAX([self minFieldOfViewDeg], degrees));
}


/////////////////////////////////////////////////////////////////
//
- (void)setMinDistanceFromLookAtPosition:(float)distance
{
   minDistanceFromLookAtPosition = distance;
}


/////////////////////////////////////////////////////////////////
//
- (void)setMaxDistanceFromLookAtPosition:(float)distance
{
   maxDistanceFromLookAtPosition = distance;
   frustum.farDistance = distance * UtilityCameraFarPlaneRatio;
}


/////////////////////////////////////////////////////////////////
//
- (void)setMaxCameraElevation:(float)anElevation
{
   maxCameraElevation = anElevation;
}


/////////////////////////////////////////////////////////////////
//
- (float)maxCameraElevation
{
   return maxCameraElevation;
}


/////////////////////////////////////////////////////////////////
//
- (void)cameraPositionDidChange:(id)sender
{
   if(self.isInitialized) 
   {
      UtilityFrustumSetPositionAndDirection
      (
       &frustum, 
       frustum.cameraPosition, 
       lookAtPosition, 
       upVector);
   }
   
   if([self.delegate respondsToSelector:
      @selector(cameraPositionDidChange:)])
   {
      [self.delegate performSelector:
          @selector(cameraPositionDidChange:) withObject:self];
   }
}

@end
