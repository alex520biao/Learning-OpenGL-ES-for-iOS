//
//  UtilityFrustum.m
//  
//

#import "UtilityFrustum.h"
#import "UtilityMath.h"


/////////////////////////////////////////////////////////////////
//
UtilityFrustum UtilityFrustumWithCameraParameters
(
 float fieldOfViewDeg, 
 float aspectRatio, 
 float nearDistance, 
 float farDistance) 
{
   NSCAssert(0.0f < fieldOfViewDeg && 180.0f > fieldOfViewDeg, 
             @"Invalid fieldOfViewDeg");
   NSCAssert(0.0f < aspectRatio, @"Invalid aspectRatio");
   NSCAssert(0.0f < nearDistance, @"Invalid nearDistance");
   NSCAssert(nearDistance < farDistance, @"Invalid farDistance");
   
   UtilityFrustum frustum;
   
   const float fieldOfViewRad = fieldOfViewDeg * 
      UtilityDegreesToRadians;
   
	// store the information
	frustum.aspectRatio = aspectRatio;
	frustum.nearDistance = nearDistance;
	frustum.farDistance = farDistance;
   
	// compute width and height of the near section
	frustum.tangentOfFieldOfView = 
      (float)tanf(fieldOfViewRad * 0.5f) ;
	frustum.sphereFactorY = 1.0f/cosf(fieldOfViewRad);
   
	// compute half of the the horizontal field of view and 
   // sphereFactorX 
	float angleX = 
      atanf(frustum.tangentOfFieldOfView * aspectRatio);
	frustum.sphereFactorX = 1.0f/cosf(angleX);
   
   return frustum;
}


/////////////////////////////////////////////////////////////////
//
void UtilityFrustumSetPositionAndDirection
(
 UtilityFrustum *frustumPtr, 
 UtilityVector3 cameraPosition, 
 UtilityVector3 cameraLookPosition, 
 UtilityVector3 cameraUpVector) 
{
   NSCAssert(NULL != frustumPtr, @"Invalid frustumPtr parameter");
   
	frustumPtr->cameraPosition = cameraPosition;
	
	// compute the Z axis of the camera referential. This axis 
   // points in the direction from position to lookAtPosition
   UtilityVector3 lookAtVector = 
   UtilityVector3FromPositionToPosition(cameraPosition, 
                                        cameraLookPosition);
   NSCAssert(0.0f < UtilityVector3LengthSquared(lookAtVector),
             @"Invalid cameraLookPosition parameter");
	frustumPtr->cameraZNormalVector = 
      UtilityVector3Normalize(lookAtVector);
   
	// X axis of camera with given "up" vector and Z axis
	frustumPtr->cameraXNormalVector = 
   UtilityVector3Normalize
   (
    UtilityVector3CrossProduct(frustumPtr->cameraZNormalVector, 
       cameraUpVector));
   
	// the frustum "up" vector is the dot product of X and Z
	frustumPtr->cameraYNormalVector = 
   UtilityVector3CrossProduct
   (
    frustumPtr->cameraXNormalVector, 
    frustumPtr->cameraZNormalVector);
}


/////////////////////////////////////////////////////////////////
//
#define UtilityFrustumMaxFieldOfViewRad ((M_PI / 2.0) - 0.1)

/////////////////////////////////////////////////////////////////
//
static BOOL UtilityFrustumHasDimention
(const UtilityFrustum *frustumPtr)
{
   NSCAssert(NULL != frustumPtr, @"Invalid frustumPtr parameter");
   
   return (frustumPtr->nearDistance < frustumPtr->farDistance) && 
   (0.0 < frustumPtr->tangentOfFieldOfView) && 
   (0.0 < fabs(frustumPtr->aspectRatio));
}


/////////////////////////////////////////////////////////////////
//
UtilityIntersectionType UtilityFrustumComparePoint
(
 const UtilityFrustum *frustumPtr, UtilityVector3 point)
{
   NSCAssert(NULL != frustumPtr, @"Invalid frustumPtr parameter");
   
   UtilityIntersectionType     result = UtilityIn;
	float                   pcz, pcx, pcy, aux;
   
	// compute vector from camera position to p
	UtilityVector3               v = 
   UtilityVector3FromPositionToPosition(
      frustumPtr->cameraPosition, point);
   
	// compute and test the Z coordinate
	pcz = UtilityVector3DotProduct
   (v, 
    UtilityVector3Scale
    (frustumPtr->cameraZNormalVector, -1.0f));
	if (pcz > frustumPtr->farDistance || 
      pcz < frustumPtr->nearDistance)
   {
		result = UtilityOut;
   }
   else
   {   
      // compute and test the Y coordinate
      pcy = UtilityVector3DotProduct(v, 
         frustumPtr->cameraYNormalVector);
      aux = pcz * frustumPtr->tangentOfFieldOfView;
      if (pcy > aux || pcy < -aux)
      {
         result = UtilityOut;
      }
      else
      {
         // compute and test the X coordinate
         pcx = UtilityVector3DotProduct(v, 
            frustumPtr->cameraXNormalVector);
         aux = aux * frustumPtr->aspectRatio;
         if (pcx > aux || pcx < -aux)
         {
            result = UtilityOut;
         }
      }
   }
   
	return result;
}


/////////////////////////////////////////////////////////////////
//
UtilityIntersectionType UtilityFrustumCompareSphere
(
 const UtilityFrustum *frustumPtr, 
 UtilityVector3 center, float radius)
{
   NSCAssert(NULL != frustumPtr, @"Invalid frustumPtr parameter");
   
   UtilityIntersectionType result = UtilityIn;
	float                   d;
	float                   az, ax, ay;  
	UtilityVector3           v = 
   UtilityVector3FromPositionToPosition(
      frustumPtr->cameraPosition, center);
   
   az = UtilityVector3DotProduct
   (v, 
    UtilityVector3Scale
    (frustumPtr->cameraZNormalVector, -1.0f));
   
	if (az > (frustumPtr->farDistance + radius) || 
       az < (frustumPtr->nearDistance - radius))
   {
		return UtilityOut;
   }
   
	if (az > (frustumPtr->farDistance - radius) || 
       az < (frustumPtr->nearDistance + radius))
   {
		result = UtilityIntersects;
   }
   
	ay = UtilityVector3DotProduct(v, 
      frustumPtr->cameraYNormalVector);
	d = frustumPtr->sphereFactorY * radius;
	az *= frustumPtr->tangentOfFieldOfView;
	if (ay > (az + d) || ay < (-az - d))
   {
		return UtilityOut;
   }
   
	if (ay > (az - d) || ay < (-az + d))
   {
		result = UtilityIntersects;
   }
   
	ax = UtilityVector3DotProduct(v, 
      frustumPtr->cameraXNormalVector);
	az *= frustumPtr->aspectRatio;
	d = frustumPtr->sphereFactorX * radius;
	if (ax > (az + d) || ax < (-az - d))
   {
		return UtilityOut;
   }
   
	if (ax > (az - d) || ax < (-az + d))
   {
		result = UtilityIntersects;
   }
   
   // Sphere is inside all planes and intersects none
   return result;
}

