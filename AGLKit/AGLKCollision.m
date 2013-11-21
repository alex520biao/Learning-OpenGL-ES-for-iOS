//
//  AGLKCollision.m
//  
//

#import "AGLKCollision.h"


/////////////////////////////////////////////////////////////////
// This function returns YES if both p1 and p2 are on the same 
// side of the line defined by a and b.
BOOL AGLKPointsAreOnSameSideOfLine(
   GLKVector3 p1, 
   GLKVector3 p2, 
   GLKVector3 a, 
   GLKVector3 b)
{
   GLKVector3      cp1 = GLKVector3CrossProduct(
      GLKVector3Subtract(b, a), GLKVector3Subtract(p1, a));
   GLKVector3      cp2 = GLKVector3CrossProduct(
      GLKVector3Subtract(b, a), GLKVector3Subtract(p2, a));
   
   return (0 <= GLKVector3DotProduct(cp1, cp2));
}


/////////////////////////////////////////////////////////////////
// This function returns YES if p is inside the triangle formed
// by a, b, and c.
BOOL AGLKPointIsInTriangle(
   GLKVector3 p, 
   GLKVector3 a, 
   GLKVector3 b, 
   GLKVector3 c)
{
   return (AGLKPointsAreOnSameSideOfLine(p, a, b, c) && 
           AGLKPointsAreOnSameSideOfLine(p, b, a, c) &&
           AGLKPointsAreOnSameSideOfLine(p, c, a, b));
}


/////////////////////////////////////////////////////////////////
// 
#define AGLKVerySmallMagnitude (FLT_EPSILON * 8.0f)


/////////////////////////////////////////////////////////////////
// This function returns the point of intersection between a ray
// and a triangle.
BOOL AGLKRayDoesIntersectTriangle(
   GLKVector3 d,
   GLKVector3 p,
   GLKVector3 v0,
   GLKVector3 v1,
   GLKVector3 v2,
   GLKVector3 *intersectionPoint)
{  // The parametric equation of the line is p + t * d where p
   // is a point in the line and d is a unit vector in the line's 
   // direction and t is a distance from p along the line.
   // If there is a point that belongs both to the line and the 
   // triangle {v0, v1, v2} then
   // p + t * d = (1-u-v) * v0 + u * v1 + v * v2
   // Is function answeres whether there a triplet (t,u,v) that 
   // satisfies the equation.
   d = GLKVector3Normalize(d);
   GLKVector3 e1 = GLKVector3Subtract(v1, v2);
   GLKVector3 e2 = GLKVector3Subtract(v2, v0);
   GLKVector3 h = GLKVector3CrossProduct(d, e2);
   GLfloat a = GLKVector3DotProduct(e1, h);
   
   if(a > -AGLKVerySmallMagnitude && a < AGLKVerySmallMagnitude)
   {  // ray and triangle are parallel and therefore don't 
      // interesct
      return NO;
   } 

   GLfloat f = 1.0f / a;
   GLKVector3 s = GLKVector3Subtract(p, v0);
   GLfloat u = f * GLKVector3DotProduct(s, h);
   
   if(u < 0.0f || u > 1.0f)
   {  // Ray passes outside side v2<-->v0
      return NO;
   } 
   
   GLKVector3 q = GLKVector3CrossProduct(s, e1);
   GLfloat v = f * GLKVector3DotProduct(d, q);
   
   if(v < 0.0f || v > 1.0f)
   {  // Ray passes outside side v1<-->v2
      return NO;
   } 
   
   // at this stage we can compute t to find out where
	// the intersection point is on the line
   GLfloat t = f * GLKVector3DotProduct(e2, q);
   
   if(t > AGLKVerySmallMagnitude)
   { // Found intersection (Ray passes inside side v0<-->v1
      if(NULL != intersectionPoint)
      {
         *intersectionPoint = GLKVector3Add(p,
            GLKVector3MultiplyScalar(d, t));
      }
      
      return YES;
   }
   
   return NO;
}
