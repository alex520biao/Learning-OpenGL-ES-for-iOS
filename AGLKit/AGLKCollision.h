//
//  AGLKCollision.h
//  
//

#import <GLKit/GLKit.h>

extern BOOL AGLKPointsAreOnSameSideOfLine(
   GLKVector3 p1, 
   GLKVector3 p2, 
   GLKVector3 linePointA, 
   GLKVector3 linePointB);

extern BOOL AGLKPointIsInTriangle(
   GLKVector3 aPoint, 
   GLKVector3 trianglePointA, 
   GLKVector3 trianglePointB, 
   GLKVector3 trianglePointC);
   
extern BOOL AGLKRayDoesIntersectTriangle(
   GLKVector3 rayDirection,
   GLKVector3 pointOnRay,
   GLKVector3 trianglePointA,
   GLKVector3 trianglePointB,
   GLKVector3 trianglePointC,
   GLKVector3 *intersectionPoint);
