//
//  AGLKFrustum.m
//  
//

#import "AGLKFrustum.h"
#include <GLKit/GLKit.h>


/////////////////////////////////////////////////////////////////
// Call to define frustum shape in the same situations when 
// gluPerspective() would be called.
// The projection matrix corresponding to the returned frustum
// can be obtained by calling AGLKFrustumMakePerspective()
// after calling this function.
AGLKFrustum AGLKFrustumMakeFrustumWithParameters
(
   GLfloat fieldOfViewRad, 
   GLfloat aspectRatio, 
   GLfloat nearDistance, 
   GLfloat farDistance) 
{
   AGLKFrustum frustum;
   
   AGLKFrustumSetPerspective(
      &frustum,
      fieldOfViewRad, 
      aspectRatio, 
      nearDistance, 
      farDistance);
      
   return frustum;
}


/////////////////////////////////////////////////////////////////
// 
extern void AGLKFrustumSetPerspective
(
   AGLKFrustum *frustumPtr, 
   GLfloat fieldOfViewRad, 
   GLfloat aspectRatio, 
   GLfloat nearDistance, 
   GLfloat farDistance 
   )
{
   NSCAssert(NULL != frustumPtr, 
      @"Invalid frustumPtr parameter");
   NSCAssert(0.0f < fieldOfViewRad && M_PI > fieldOfViewRad, 
      @"Invalid fieldOfViewRad");
   NSCAssert(0.0f < aspectRatio, @"Invalid aspectRatio");
   NSCAssert(0.0f < nearDistance, @"Invalid nearDistance");
   NSCAssert(nearDistance < farDistance, @"Invalid farDistance");
   
   const GLfloat halfFieldOfViewRad = 0.5f * fieldOfViewRad;
   
   // store the information
   frustumPtr->aspectRatio = aspectRatio;
   frustumPtr->nearDistance = nearDistance;
   frustumPtr->farDistance = farDistance;
   
   // compute width and height of the near section
   frustumPtr->tangentOfHalfFieldOfView = 
      tanf(halfFieldOfViewRad);
   frustumPtr->nearHeight = nearDistance * 
      frustumPtr->tangentOfHalfFieldOfView;
   frustumPtr->nearWidth = frustumPtr->nearHeight * aspectRatio;

   // Calculate sphere factors (used when testing sphere 
   // intersection with frustum)
   frustumPtr->sphereFactorY =     
      1.0f/cosf(frustumPtr->tangentOfHalfFieldOfView);
   const GLfloat angleX = 
      atanf(frustumPtr->tangentOfHalfFieldOfView * aspectRatio);
   frustumPtr->sphereFactorX = 1.0f/cosf(angleX);
}


/////////////////////////////////////////////////////////////////
// Quickly calculate length squared of vector. Use in cases where
// lengths are compared and comparing lengths squared is just as
// valid. Use to avoid expensive sqrt() function call.
static __inline__ GLfloat AGLKVector3LengthSquared(
   GLKVector3 vector
   )
{
   return (
      vector.v[0] * vector.v[0] + 
      vector.v[1] * vector.v[1] + 
      vector.v[2] * vector.v[2]
   );
}


/////////////////////////////////////////////////////////////////
// Call in the same situations when glLookAt() would be called.
// The modelview matrix corresponding to the specified frustum 
// point of view can be obtained by calling 
// AGLKFrustumMakeModelview() after this function has been 
// called.
void AGLKFrustumSetPositionAndDirection
(
 AGLKFrustum *frustumPtr, 
 GLKVector3 eyePosition, 
 GLKVector3 lookAtPosition, 
 GLKVector3 upVector) 
{
   NSCAssert(NULL != frustumPtr, 
      @"Invalid frustumPtr parameter");
   
	frustumPtr->eyePosition = eyePosition;
	
	// compute the Z axis of the frustum. The Z axis points in  
   // the direction from eye position to look at position
   const GLKVector3 lookAtVector = 
      GLKVector3Subtract(eyePosition, lookAtPosition);
   NSCAssert(0.0f < AGLKVector3LengthSquared(lookAtVector),
             @"Invalid eyeLookPosition parameter");
	frustumPtr->zUnitVector = GLKVector3Normalize(lookAtVector);
   
   // The frustum's X axis is the cross product of the 
   // normalized “up” vector and the frustum's Z axis  
   frustumPtr->xUnitVector = GLKVector3CrossProduct(
      GLKVector3Normalize(upVector),
      frustumPtr->zUnitVector);
   
	// The frustum's Y axis is the cross product of the 
   // frustum's Z axis and the frustum's X axis.
	frustumPtr->yUnitVector = GLKVector3CrossProduct(
      frustumPtr->zUnitVector,
      frustumPtr->xUnitVector);
}


/////////////////////////////////////////////////////////////////
// 
void AGLKFrustumSetToMatchModelview
(
   AGLKFrustum *frustumPtr,
   GLKMatrix4 modelview
)
{
   frustumPtr->xUnitVector = GLKVector3Make(
      modelview.m00, modelview.m10, modelview.m20);
   frustumPtr->yUnitVector = GLKVector3Make(
      modelview.m01, modelview.m11, modelview.m21);
   frustumPtr->zUnitVector = GLKVector3Make(
      modelview.m02, modelview.m12, modelview.m22);
}


/////////////////////////////////////////////////////////////////
// Returns YES if the frustum has been initialized. No otherwise.
BOOL AGLKFrustumHasDimention
(const AGLKFrustum *frustumPtr)
{
   NSCAssert(NULL != frustumPtr, @"Invalid frustumPtr parameter");
   
   return (frustumPtr->nearDistance < frustumPtr->farDistance) &&
   (0.0f < frustumPtr->tangentOfHalfFieldOfView) &&  
   (0.0f < fabs(frustumPtr->aspectRatio));
}


/////////////////////////////////////////////////////////////////
// Returns whether point is inside or outside frustumPtr  
AGLKFrustumIntersectionType AGLKFrustumComparePoint
(
 const AGLKFrustum *frustumPtr, GLKVector3 point)
{
   NSCAssert(AGLKFrustumHasDimention(frustumPtr), 
      @"Invalid frustumPtr parameter");
   
   AGLKFrustumIntersectionType result = AGLKFrustumIn;
   
   // compute vector from eye position to point
   const GLKVector3 eyeToPoint = GLKVector3Subtract(
      frustumPtr->eyePosition, point);
   
   // compute and test Z coordinate within frustum
   const GLfloat pointZComponent = GLKVector3DotProduct(
      eyeToPoint, frustumPtr->zUnitVector);

   if(pointZComponent > frustumPtr->farDistance || 
      pointZComponent < frustumPtr->nearDistance)
   {  // The point is not within frustum
		result = AGLKFrustumOut;
   }
   else
   {   
      // compute and test Y coordinate within frustum
      const GLfloat pointYComponent = 
         GLKVector3DotProduct(eyeToPoint, 
            frustumPtr->yUnitVector);
      const GLfloat frustumHeightAtZ = pointZComponent * 
         frustumPtr->tangentOfHalfFieldOfView;
         
      if(pointYComponent > frustumHeightAtZ || 
         pointYComponent < -frustumHeightAtZ)
      {  // The point is not within frustum
         result = AGLKFrustumOut;
      }
      else
      {  // compute and test the X coordinate within frustum
         const GLfloat pointXComponent = 
            GLKVector3DotProduct(eyeToPoint, 
               frustumPtr->xUnitVector);
         const GLfloat frustumWidthAtZ = frustumHeightAtZ * 
            frustumPtr->aspectRatio;
            
         if(pointXComponent > frustumWidthAtZ || 
            pointXComponent < -frustumWidthAtZ)
         {  // The point is not within frustum
            result = AGLKFrustumOut;
         }
      }
   }
   
	return result;
}


/////////////////////////////////////////////////////////////////
// Returns whether sphere specified by center and radius is 
// inside, outside, or intersects frustumPtr.
AGLKFrustumIntersectionType AGLKFrustumCompareSphere
(
 const AGLKFrustum *frustumPtr, 
 GLKVector3 center, GLfloat radius)
{
   NSCAssert(AGLKFrustumHasDimention(frustumPtr), 
      @"Invalid frustumPtr parameter");
   
   AGLKFrustumIntersectionType result = AGLKFrustumIn;

	// compute vector from eye position to point
	const GLKVector3 eyeToCenter = 
      GLKVector3Subtract(
         frustumPtr->eyePosition, center);
   
	// compute and test Z diameter within frustum
	const GLfloat centerZComponent = 
      GLKVector3DotProduct(eyeToCenter,
         frustumPtr->zUnitVector);
	if (centerZComponent > (frustumPtr->farDistance + radius) || 
      centerZComponent < (frustumPtr->nearDistance - radius))
   {  // The sphere is not within frustum
		result = AGLKFrustumOut;
   }
   else if(centerZComponent > (frustumPtr->farDistance - radius) || 
      centerZComponent < (frustumPtr->nearDistance + radius))
   {  // the sphere intersects the frustum
		result = AGLKFrustumIntersects;
   }
   
   if(AGLKFrustumOut != result)
   {
      const GLfloat centerYComponent = 
         GLKVector3DotProduct(eyeToCenter, 
            frustumPtr->yUnitVector);
      const GLfloat yDistance = 
         frustumPtr->sphereFactorY * radius;
      const GLfloat frustumHalfHeightAtZ = 
         centerZComponent * frustumPtr->tangentOfHalfFieldOfView;
         
      if(centerYComponent > (frustumHalfHeightAtZ + yDistance) || 
         centerYComponent < (-frustumHalfHeightAtZ - yDistance))
      {  // The sphere is not within frustum
         result = AGLKFrustumOut;
      }
      else if(centerYComponent > (frustumHalfHeightAtZ - yDistance) || 
         centerYComponent < (-frustumHalfHeightAtZ + yDistance))
      {  // the sphere intersects the frustum
         result = AGLKFrustumIntersects;
      }
      
      if(AGLKFrustumOut != result)
      {
         const GLfloat centerXComponent = 
            GLKVector3DotProduct(eyeToCenter, 
               frustumPtr->xUnitVector);
         const GLfloat xDistance = 
            frustumPtr->sphereFactorX * radius;
         const GLfloat frustumHalfWidthAtZ = 
            frustumHalfHeightAtZ * frustumPtr->aspectRatio;
            
         if(centerXComponent > (frustumHalfWidthAtZ + xDistance) || 
            centerXComponent < (-frustumHalfWidthAtZ - xDistance))
         {  // The sphere is not within frustum
            result = AGLKFrustumOut;
         }
         else if(centerXComponent > (frustumHalfWidthAtZ - xDistance) || 
            centerXComponent < (-frustumHalfWidthAtZ + xDistance))
         {  // the sphere intersects the frustum
            result = AGLKFrustumIntersects;
         }
      }
   }

   return result;
}


/////////////////////////////////////////////////////////////////
// Returns a projection matrix that encodes perspective
// matching the specified frustum
extern GLKMatrix4 AGLKFrustumMakePerspective
(
 const AGLKFrustum *frustumPtr
 )
{
   NSCAssert(AGLKFrustumHasDimention(frustumPtr), 
      @"Invalid frustumPtr parameter");

   const GLfloat cotan = 
      1.0f / frustumPtr->tangentOfHalfFieldOfView;
   const GLfloat nearZ = frustumPtr->nearDistance;
   const GLfloat farZ = frustumPtr->farDistance;
   
   GLKMatrix4 m = { 
      cotan / frustumPtr->aspectRatio, 0.0f, 0.0f, 0.0f,
      0.0f, cotan, 0.0f, 0.0f,
      0.0f, 0.0f, (farZ + nearZ) / (nearZ - farZ), -1.0f,
      0.0f, 0.0f, (2.0f * farZ * nearZ) / (nearZ - farZ), 0.0f
   };

   return m;
}

/////////////////////////////////////////////////////////////////
// Returns a modelview matrix that encodes the point of view
// matching the specified frustum
GLKMatrix4 AGLKFrustumMakeModelview
(
 const AGLKFrustum *frustumPtr) 
{
   NSCAssert(AGLKFrustumHasDimention(frustumPtr), 
      @"Invalid frustumPtr parameter");

   const GLKVector3 eyePosition = frustumPtr->eyePosition;
   const GLKVector3 xNormal = frustumPtr->xUnitVector;
   const GLKVector3 yNormal = frustumPtr->yUnitVector;
   const GLKVector3 zNormal = frustumPtr->zUnitVector;
   const GLfloat xTranslation = GLKVector3DotProduct(
      xNormal, eyePosition);
   const GLfloat yTranslation = GLKVector3DotProduct(
      yNormal, eyePosition);
   const GLfloat zTranslation = GLKVector3DotProduct(
      zNormal, eyePosition);
      
   GLKMatrix4 m = {
      // X Axis     Y Axis     Z Axis 
      xNormal.x, yNormal.x, zNormal.x,             0.0f,
      xNormal.y, yNormal.y, zNormal.y,             0.0f,
      xNormal.z, yNormal.z, zNormal.z,             0.0f,

      // Axis Origin
      -xTranslation, -yTranslation, -zTranslation, 1.0f
   };
    
   return m;
}
