//
//  TETerrain+modelAdditions.m
//  OpenGLES_Ch12_1
//

#import "TETerrain+modelAdditions.h"
#import "AGLKCollision.h"


@implementation TETerrain (modelAdditions)

/////////////////////////////////////////////////////////////////
// This function returns a pointer to a vector storing the X,Y,Z 
// coordinates the vertex corresponding to the x,z position in 
// terrain. 
static inline const GLKVector3 *TETerrainPostitionPtrAt
(
 TETerrain *terrain,
 NSData *positionAttributes,
 NSInteger x,
 NSInteger z)
{
   NSCParameterAssert(nil != terrain);
   NSCParameterAssert(nil != positionAttributes);
   NSCParameterAssert(x >= 0 && x < terrain.width);
   NSCParameterAssert(z >= 0 && z < terrain.length);
   
   return ((const GLKVector3 *)[positionAttributes bytes]) +
   (z * terrain.width + x);
}


/////////////////////////////////////////////////////////////////
// Return the calculated height of the terrain in meters at 
// position x,z in terrain mesh coordinates.  Use this method 
// when height at the nearest terrain mesh vertex isn't precise 
// enough.
- (GLfloat)calculatedHeightAtXPos:(GLfloat)x zPos:(GLfloat)z
   surfaceNormal:(GLKVector3 *)aNormal;
{
   GLfloat       result = 0.0f;
   GLfloat metersPerUnit = self.metersPerUnit;
   
   // First, find out which triangle contains the point 
   GLKVector3 a = {floorf(x), 0.0f, floorf(z)};
   GLKVector3 b = {floorf(x), 0.0f, ceilf(z + 0.0001)};
   GLKVector3 c = {ceilf(x + 0.0001), 0.0f, floorf(z)};
   GLKVector3 d = {ceilf(x + 0.0001), 0.0f, ceilf(z + 0.0001)};
   GLKVector3 p = {x, 0.0f, z};
   GLKVector3 rayDirection = {0.0f, 1.0f, 0.0f};
   
   a.y = [self heightAtXPos:a.x zPos:a.z] / metersPerUnit;
   b.y = [self heightAtXPos:b.x zPos:b.z] / metersPerUnit;
   c.y = [self heightAtXPos:c.x zPos:c.z] / metersPerUnit;
   d.y = [self heightAtXPos:d.x zPos:d.z] / metersPerUnit;
   
   GLKVector3 intersectionPoint;
   
   if(AGLKRayDoesIntersectTriangle(
      rayDirection,
      p,
      a,
      b,
      c,
      &intersectionPoint))
   {
      if(NULL != aNormal)
      {
         *aNormal = GLKVector3CrossProduct(
            GLKVector3Normalize(GLKVector3Subtract(b, a)),
            GLKVector3Normalize(GLKVector3Subtract(c, a)));
      }
      result = intersectionPoint.y * metersPerUnit;
   }
   else if(AGLKRayDoesIntersectTriangle(
      rayDirection,
      p,
      d,
      b,
      c,
      &intersectionPoint)
      )
   {
      if(NULL != aNormal)
      {
         *aNormal = GLKVector3CrossProduct(
            GLKVector3Normalize(GLKVector3Subtract(c, d)),
            GLKVector3Normalize(GLKVector3Subtract(b, d)));
            
         NSAssert(0.9 < GLKVector3DotProduct(
            *aNormal, 
            *aNormal),
            @"Invalid surfaceNormal");
      }
      result = intersectionPoint.y * metersPerUnit;
   }
   
      
   return result;
}


/////////////////////////////////////////////////////////////////
// Return the calculated height of the terrain in meters at 
// position x,z in meters.  Use this method when height at the
// nearest terrain mesh vertex isn't precise enough.
- (GLfloat)calculatedHeightAtXPosMeters:(GLfloat)x 
   zPosMeters:(GLfloat)z
   surfaceNormal:(GLKVector3 *)aNormal;
{
   GLfloat metersPerUnit = self.metersPerUnit;
   x = x / metersPerUnit;
   z = z / metersPerUnit;
   
   GLfloat result = [self calculatedHeightAtXPos:x zPos:z
      surfaceNormal:aNormal];
      
   return result;
}


/////////////////////////////////////////////////////////////////
// Return the height of the terrain in meters at position x,z in
// terrain mesh coordinates. 
- (GLfloat)heightAtXPos:(NSInteger)x zPos:(NSInteger)z
{
   GLfloat       result = 0.0f;
   const NSInteger constLength = self.length;
   const NSInteger constWidth = self.width;
   
   if(nil != self.positionAttributesData && x < constWidth && 
      z < constLength && 0 <= x && 0 <= z)
   {
      result = TETerrainPostitionPtrAt(
         self, self.positionAttributesData, x, z)->y;
   }
   
   return result;
}


/////////////////////////////////////////////////////////////////
// Return the height of the terrain in meters at position x,z in
// meters. 
- (GLfloat)heightAtXPosMeters:(GLfloat)x zPosMeters:(GLfloat)z;
{
   GLfloat metersPerUnit = self.metersPerUnit;
   x = x / metersPerUnit;
   z = z / metersPerUnit;
   
   return [self heightAtXPos:x zPos:z];
}


/////////////////////////////////////////////////////////////////
// Return the highest height in meters of the terrain near 
// position x,z. 
- (GLfloat)maxHeightNearXPosMeters:(NSInteger)x 
   zPosMeters:(NSInteger)z;
{
   NSParameterAssert([self isHeightValidAtXPosMeters:x 
      zPosMeters:z]);

   const GLfloat constMetersPerUnit = 
      self.metersPerUnit;
   NSAssert(0 < constMetersPerUnit, @"Invalid dimensions");
   
   x /= constMetersPerUnit;
   z /= constMetersPerUnit;
   
   GLfloat   maxNearbyHeight = [self heightAtXPos:x zPos:z];
   NSInteger zIndex;
	NSInteger xIndex;
   
   for(zIndex = z-1; zIndex <= z+1; zIndex++)
   {
      for(xIndex = x-1; xIndex <= x+1; xIndex++) 
      {
         if([self isHeightValidAtXPos:xIndex zPos:zIndex])
         {
            maxNearbyHeight = MAX(maxNearbyHeight,
              [self heightAtXPos:xIndex zPos:zIndex]);
         }
      }
   }
   
   return maxNearbyHeight;
}


/////////////////////////////////////////////////////////////////
// Returns YES if and only if a valid height value is available
// for the terrain at position x,z.
- (BOOL)isHeightValidAtXPos:(NSInteger)x zPos:(NSInteger)z
{
   const NSInteger constLength = self.length;
   const NSInteger constWidth = self.width;

   return (x < constWidth && z < constLength && 0 <= x && 0 <= z);
}


/////////////////////////////////////////////////////////////////
// Returns the height in meters of the terrain at the specified
// location in meters.
- (BOOL)isHeightValidAtXPosMeters:(NSInteger)x 
   zPosMeters:(NSInteger)z;
{
   const GLfloat constMetersPerUnit = 
      self.metersPerUnit;
   NSAssert(0 < constMetersPerUnit, @"Invalid dimensions");
   
   x /= constMetersPerUnit;
   z /= constMetersPerUnit;
   
   return [self isHeightValidAtXPos:x zPos:z];
}


/////////////////////////////////////////////////////////////////
// Returns the average of the up to 9 mesh vertices 
// centered at x,z  
- (GLfloat)regionalHeightAtXPosMeters:(NSInteger)x 
   zPosMeters:(NSInteger)z
{  
   const GLfloat constMetersPerUnit = 
      self.metersPerUnit;
   NSAssert(0 < constMetersPerUnit, @"Invalid dimensions");
   
   x /= constMetersPerUnit;
   z /= constMetersPerUnit;
   
   NSParameterAssert([self isHeightValidAtXPos:x zPos:z]);

   NSInteger  zIndex;
	NSInteger xIndex;
   GLfloat count = 0.0f;
   GLfloat heightSum = 0.0;
   GLfloat heightAverage = 0.0;
   
   for(zIndex = z-1; zIndex <= z+1; zIndex++)
   {
      for(xIndex = x-1; xIndex <= x+1; xIndex++) 
      {
         if([self isHeightValidAtXPos:xIndex zPos:zIndex])
         {
            heightSum += [self heightAtXPos:xIndex zPos:zIndex];
            count += 1.0f;
         }
      }
   }
   if(0.0f < count)
   {
      heightAverage = heightSum / count;
   }
   
   return heightAverage;
}


/////////////////////////////////////////////////////////////////
// Returns the width of the terrain in meters based on the 
// receiver's metersPerUnit property.
- (GLfloat)widthMeters;
{
   return self.width * self.metersPerUnit;
}


/////////////////////////////////////////////////////////////////
// Returns the maximum height of the terrain in meters based on 
// the receiver's metersPerUnit property.
- (GLfloat)heightMeters;
{
   return self.heightScaleFactor * self.metersPerUnit;
}


/////////////////////////////////////////////////////////////////
// Returns the length of the terrain in meters based on the 
// receiver's metersPerUnit property.
- (GLfloat)lengthMeters;
{
   return self.length * self.metersPerUnit;
}

@end
