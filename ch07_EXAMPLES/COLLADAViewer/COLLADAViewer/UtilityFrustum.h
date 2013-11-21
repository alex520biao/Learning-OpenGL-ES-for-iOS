//
//  UtilityFrustum.h
//  
//

#import "UtilityMath.h"


/////////////////////////////////////////////////////////////////
// This data type is used to store the parameters that define a  
// viewing frustum
typedef struct 
{
	UtilityVector3       cameraPosition;
	UtilityVector3       cameraXNormalVector;
  UtilityVector3       cameraYNormalVector;
  UtilityVector3       cameraZNormalVector;
	GLfloat             nearDistance;
  GLfloat             farDistance;
  GLfloat             aspectRatio;
  GLfloat             tangentOfFieldOfView;
	GLfloat             sphereFactorX;
  GLfloat             sphereFactorY;
}
UtilityFrustum;


/////////////////////////////////////////////////////////////////
// This data type enumerates the possible intersetions of 
// geometry with a frustum.  The geometry is potetially entirely
// within the frustum, partially within the frustum, or 
// completely outside the frustum.
typedef enum
{
  UtilityIn,
  UtilityIntersects,
  UtilityOut,
} 
UtilityIntersectionType;


/////////////////////////////////////////////////////////////////
// 
extern UtilityFrustum UtilityFrustumWithCameraParameters
(
 GLfloat fieldOfViewDeg, 
 GLfloat aspectRatio, 
 GLfloat nearDistance, 
 GLfloat farDistance
 );

/////////////////////////////////////////////////////////////////
// 
extern void UtilityFrustumSetPositionAndDirection
(
 UtilityFrustum *frustumPtr, 
 UtilityVector3 position, 
 UtilityVector3 lookAtPosition, 
 UtilityVector3 up
 );

/////////////////////////////////////////////////////////////////
// 
extern UtilityIntersectionType UtilityFrustumComparePoint
(
 const UtilityFrustum *frustumPtr, 
 UtilityVector3 point
 );

/////////////////////////////////////////////////////////////////
// 
extern UtilityIntersectionType UtilityFrustumCompareSphere
(
 const UtilityFrustum *frustumPtr, 
 UtilityVector3 center, 
 float radius
 );
