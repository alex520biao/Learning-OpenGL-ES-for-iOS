//
//  UtilityOpenGLCamera.m
//  
//

#import "UtilityOpenGLCamera.h"
#import "UtilityMath.h"
#include <OpenGL/glu.h>

#define UtilityCameraMaxFieldOfViewDeg (175.0f)
#define UtilityCameraMinFieldOfViewDeg (1.0f)


/////////////////////////////////////////////////////////////////
//
@interface UtilityOpenGLCamera ()
{
	UtilityVector3  lookAtPosition;
	UtilityVector3 upVector; 
   GLfloat fieldOfViewDeg;  
   GLfloat maxDistanceFromLookAtPosition;
   GLfloat minDistanceFromLookAtPosition;
   GLfloat maxCameraElevation;
   GLfloat top;
   GLfloat bottom;
   GLfloat left;
   GLfloat right;
   UtilityFrustum frustum;
   BOOL isInitialized;
   BOOL isUpdatingPosition;
}

@property (nonatomic, assign, readwrite) BOOL isInitialized;

- (void)recalcInternalStateWithPosition:(UtilityVector3)aPosition 
   lookAtPosition:(UtilityVector3)aLookAtPosition 
   distanceConstraint:(GLfloat)aDistanceConstraint;
   
@end


/////////////////////////////////////////////////////////////////
//
@implementation UtilityOpenGLCamera

static const GLfloat _UtilityDefaultMaxZoom = (6.0f);
static const GLfloat _UtilityDefaultMinZoom = (0.1f);
static const UtilityVector3 _UtilityDefaultLookAtPosition = 
   {0.0f, 0.0f, 0.0f};   
static const UtilityVector3 _UtilityDefaultUpVector = 
   {0.0f, 1.0f, 0.0f};   
static const UtilityVector3 _UtilityDefaultPosition = 
   {1.0f, 1.0f, 1.0f};   
static const GLfloat _UtilityDefaultFieldOfViewDeg = 45.0f;
static const GLfloat _UtilityDefaultAspectRatio = 1.0f;
static const GLfloat _UtilityDefaultMinDistance = 0.2f;
static const GLfloat _UtilityDefaultNearDistance = 0.2f;
static const GLfloat _UtilityDefaultFarDistance = 4000.0f;

@synthesize isInitialized;
@synthesize delegate;
@synthesize upVector;
@synthesize fieldOfViewDeg;
@synthesize lookAtPosition;



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
      maxDistanceFromLookAtPosition = _UtilityDefaultFarDistance;
      minDistanceFromLookAtPosition = _UtilityDefaultNearDistance;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//
- (UtilityMatrix4)projectionMatrix;
{
   return UtilityMatrix4MakeFrustum(
      left, 
      right, 
      bottom, 
      top, 
      frustum.nearDistance, 
      frustum.farDistance);
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
         MIN(_UtilityDefaultNearDistance, frustum.nearDistance)), 
      frustum.farDistance);

   UtilityFrustumSetPositionAndDirection
   (&frustum, cameraPosition, lookAtPosition, upVector);

   {
      top = frustum.nearDistance * tan
      (UtilityDegreesToRadians * fieldOfViewDeg / 2.0f);
      bottom = -top;
      right = frustum.aspectRatio * top;
      left = -right;
   }

   self.isInitialized = YES;
}


/////////////////////////////////////////////////////////////////
//
- (UtilityMatrix4)modelviewMatrix;
{
   return UtilityMatrix4MakeLookAt(frustum.cameraPosition.x, 
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
- (void)moveBy:(UtilityVector3)aVector
{
   [self setLookAtPosition:UtilityVector3Add(
      [self lookAtPosition], aVector)]; 
   [self setPosition:UtilityVector3Add(
      [self position], aVector)]; 
}


/////////////////////////////////////////////////////////////////
//
- (UtilityVector3)upVector
{
	return UtilityVector3Normalize(upVector);
}


/////////////////////////////////////////////////////////////////
//
- (UtilityVector3)forwardVector
{
	return UtilityVector3Normalize( 
      UtilityVector3FromPositionToPosition(
         frustum.cameraPosition, 
         lookAtPosition));
}


/////////////////////////////////////////////////////////////////
//
- (UtilityVector3)rightVector
{
	// X axis of camera with given "up" vector and Z axis
	UtilityVector3   xNormalVector = UtilityVector3Normalize(
      UtilityVector3CrossProduct(self.forwardVector, upVector));
      
   return xNormalVector;
}


/////////////////////////////////////////////////////////////////
//
- (void)panDeltaForward:(GLfloat)aDelta;
{
	// compute the Z axis of the camera referential.  this axis 
   // points in the same direction from the looking direction
	UtilityVector3   zNormalVector = 
      UtilityVector3FromPositionToPosition(
         frustum.cameraPosition, 
         lookAtPosition);
   zNormalVector.y = 0.0;
         
   zNormalVector = UtilityVector3Normalize(zNormalVector);
   
   [self moveBy:UtilityVector3Scale(zNormalVector, aDelta)];
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
   UtilityVector3   moveVector = UtilityVector3Add(
       panXVector, panYVector);
   
   [self moveBy:moveVector];
}


/////////////////////////////////////////////////////////////////
//
- (void)rotateAngleRadiansAboutY:(GLfloat)anAngleRadians
{
   anAngleRadians = fmod(anAngleRadians, Utility2PI);
   
   NSLog(@"angleDegreesAboutY = %f", UtilityRadiansToDegrees * 
     anAngleRadians);
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
   distanceConstraint:(GLfloat)aDistanceConstraint
{
   [self setPosition:aPosition];
   [self setDistanceFromLookAtPosition:UtilityVector3Length(
     UtilityVector3FromPositionToPosition(aPosition, 
        aLookAtPosition))];
   [self setLookAtPosition:aLookAtPosition];
}


/////////////////////////////////////////////////////////////////
//
- (GLfloat)distanceFromLookAtPosition
{
   UtilityVector3   curentLookAtPosition = [self lookAtPosition];
   UtilityVector3   currentPosition = [self position];
   
   return UtilityVector3Length(
      UtilityVector3FromPositionToPosition(
         currentPosition, curentLookAtPosition));
}


/////////////////////////////////////////////////////////////////
//
- (void)setDistanceFromLookAtPosition:(GLfloat)distance
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
- (void)setFieldOfViewDeg:(GLfloat)degrees
{
   fieldOfViewDeg = MIN(UtilityCameraMaxFieldOfViewDeg, 
      MAX(UtilityCameraMinFieldOfViewDeg, degrees));
}


/////////////////////////////////////////////////////////////////
//
- (void)cameraPositionDidChange:(UtilityOpenGLCamera *)sender;
{
   // prevent recursion so that delegate can reassign position
   if(!isUpdatingPosition)
   { 
      isUpdatingPosition = YES;
      if([self.delegate respondsToSelector:
         @selector(cameraPositionDidChange:)])
      {
         [self.delegate performSelector:
             @selector(cameraPositionDidChange:) withObject:self];
      }
      isUpdatingPosition = NO;

      if(self.isInitialized) 
      {
         UtilityFrustumSetPositionAndDirection
         (
          &frustum, 
          frustum.cameraPosition, 
          lookAtPosition, 
          upVector);
      }      
   }
}

@end
