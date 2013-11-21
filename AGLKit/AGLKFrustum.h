//
//  AGLKFrustum.h
//  
//

#import <GLKit/GLKit.h>


/////////////////////////////////////////////////////////////////
// This data type is used to store the parameters that define a  
// viewing frustum
typedef struct 
{  // Frustum definition
   GLKVector3 eyePosition;
   GLKVector3 xUnitVector;
   GLKVector3 yUnitVector;
   GLKVector3 zUnitVector;
   GLfloat aspectRatio;
   GLfloat nearDistance;
   GLfloat farDistance;
   
   // Derived frustum properties
   GLfloat nearWidth;
   GLfloat nearHeight;
   GLfloat tangentOfHalfFieldOfView;
   GLfloat sphereFactorX;
   GLfloat sphereFactorY;
}
AGLKFrustum;


/////////////////////////////////////////////////////////////////
// This data type enumerates the possible intersections of 
// geometry with a frustum.  The geometry is potentially entirely
// within the frustum, partially within the frustum, or 
// completely outside the frustum.
typedef enum
{
  AGLKFrustumIn,
  AGLKFrustumIntersects,
  AGLKFrustumOut,
} 
AGLKFrustumIntersectionType;


/////////////////////////////////////////////////////////////////
// 
extern AGLKFrustum AGLKFrustumMakeFrustumWithParameters
(
   GLfloat fieldOfViewRad, 
   GLfloat aspectRatio, 
   GLfloat nearDistance, 
   GLfloat farDistance 
   );

/////////////////////////////////////////////////////////////////
// 
extern void AGLKFrustumSetPerspective
(
   AGLKFrustum *frustumPtr, 
   GLfloat fieldOfViewRad, 
   GLfloat aspectRatio, 
   GLfloat nearDistance, 
   GLfloat farDistance 
   );

/////////////////////////////////////////////////////////////////
// 
extern void AGLKFrustumSetPositionAndDirection
(
 AGLKFrustum *frustumPtr, 
 GLKVector3 position, 
 GLKVector3 lookAtPosition, 
 GLKVector3 up
 );

/////////////////////////////////////////////////////////////////
// 
extern void AGLKFrustumSetToMatchModelview
(
   AGLKFrustum *frustumPtr,
   GLKMatrix4 modelview
   ); 

/////////////////////////////////////////////////////////////////
// 
extern BOOL AGLKFrustumHasDimention
(
   const AGLKFrustum *frustumPtr
   );
      
/////////////////////////////////////////////////////////////////
// 
extern AGLKFrustumIntersectionType AGLKFrustumComparePoint
(
 const AGLKFrustum *frustumPtr, 
 GLKVector3 point
 );

/////////////////////////////////////////////////////////////////
// 
extern AGLKFrustumIntersectionType AGLKFrustumCompareSphere
(
 const AGLKFrustum *frustumPtr, 
 GLKVector3 center, 
 GLfloat radius
 );

/////////////////////////////////////////////////////////////////
// 
extern GLKMatrix4 AGLKFrustumMakePerspective
(
 const AGLKFrustum *frustumPtr
 );

/////////////////////////////////////////////////////////////////
// 
extern GLKMatrix4 AGLKFrustumMakeModelview
(
 const AGLKFrustum *frustumPtr
 );
