//
//  UtilityVector.c
//  
//

#include "UtilityVector.h"


/////////////////////////////////////////////////////////////////
// This function returns an initialized vector.
UtilityVector3 UtilityVector3MakeWithArray
(
 const GLfloat v[3]
 )
{
   return UtilityVector3Make(v[0], v[1], v[2]);
}


/////////////////////////////////////////////////////////////////
// This function returns an initialized vector.
UtilityVector3 UtilityVector3Make(
   const GLfloat x, 
   const GLfloat y,
   const GLfloat z)
{
   UtilityVector3 result;
   
   result.x = x;
   result.y = y;
   result.z = z;

   return result;
}   


/////////////////////////////////////////////////////////////////
// This function returns an initialized vector.
UtilityVector2 UtilityVector2Make(
   const GLfloat x, 
   const GLfloat y)
{
   UtilityVector2 result;
   
   result.x = x;
   result.y = y;

   return result;
}   


/////////////////////////////////////////////////////////////////
// This function returns an initialized vector.
extern UtilityVector4 UtilityVector4MakeWithArray
(
 const GLfloat v[4]
 )
{
   return UtilityVector4Make(v[0], v[1], v[2], v[3]);
}


/////////////////////////////////////////////////////////////////
// This function returns an initialized vector.
extern UtilityVector4 UtilityVector4Make
(
 const GLfloat x, 
 const GLfloat y,
 const GLfloat z,
 const GLfloat w
 )
{
   UtilityVector4 result;
   
   result.x = x;
   result.y = y;
   result.z = z;
   result.w = w;

   return result;
}   



/////////////////////////////////////////////////////////////////
// This function returns the vector sum of vectorA and vectorB.
UtilityVector3 UtilityVector3Add(
   const UtilityVector3 vectorA, 
   const UtilityVector3 vectorB)
{
   return UtilityVector3Make(
      vectorA.x + vectorB.x, 
      vectorA.y + vectorB.y,
      vectorA.z + vectorB.z);
}
   
   
/////////////////////////////////////////////////////////////////
// This function returns the vector from PositionA to PositionB
extern UtilityVector3 UtilityVector3FromPositionToPosition(
   const UtilityPosition positionA, 
   const UtilityPosition positionB)
{
   return UtilityVector3Make(positionB.x - positionA.x,
      positionB.y - positionA.y,
      positionB.z - positionA.z);
}
  
   
/////////////////////////////////////////////////////////////////
// This function returnsa - b
UtilityVector3 UtilityVector3Subtract(
   const UtilityVector3 a, 
   const UtilityVector3 b)
{
	UtilityVector3      result;
   
	result.x = a.x - b.x;
	result.y = a.y - b.y;
	result.z = a.z - b.z;
   
	return (result);
}


/////////////////////////////////////////////////////////////////
// This function returns vectorA multiplied by the scalar
// scalefactor; The returned vector has changed magnitude but 
// the same direction as vectorA.
UtilityVector3 UtilityVector3Scale(
   const UtilityVector3 vectorA, 
   const GLfloat scalefactor)
{
   return UtilityVector3Make(
      vectorA.x * scalefactor, 
      vectorA.y * scalefactor,
      vectorA.z * scalefactor);
}


/////////////////////////////////////////////////////////////////
// This function returns the length squared a.k.a. magnitude of 
// vectorA squared.
extern GLfloat UtilityVector3LengthSquared(
   const UtilityVector3 vectorA)
{
   float lengthSquared = (vectorA.x * vectorA.x) + 
      (vectorA.y * vectorA.y) + 
      (vectorA.z * vectorA.z);
      
   return lengthSquared;
}


/////////////////////////////////////////////////////////////////
// This function returns the length a.k.a. magnitude of vectorA.
GLfloat UtilityVector3Length(
   const UtilityVector3 vectorA) 
{
   float result = 0.0f;
   float lengthSquared = UtilityVector3LengthSquared(vectorA);


   if(FLT_EPSILON < lengthSquared)
   {  // avoid square root of zero error if lengthSquared 
      // is too small
      result = sqrtf(lengthSquared);
   }

   return result;
}


/////////////////////////////////////////////////////////////////
// This function returns a Unit Vector with the same direction as
// vectorA.
UtilityVector3 UtilityVector3Normalize(
   UtilityVector3 vectorA)
{
   const GLfloat	length = UtilityVector3Length(vectorA);
   float          oneOverLength = 0.0f;

   if(FLT_EPSILON < length)
   {  // avoid divide by zero if length too small
      oneOverLength = 1.0f / length;
   }
         
   return UtilityVector3Scale(vectorA, oneOverLength);
}


/////////////////////////////////////////////////////////////////
// This function returns the Cross Product vectorA x VectorB.
UtilityVector3 UtilityVector3CrossProduct(
   const UtilityVector3 vectorA, 
   const UtilityVector3 vectorB)
{
   UtilityVector3 result;

   result.x = vectorA.y * vectorB.z - vectorA.z * vectorB.y;
   result.y = vectorA.z * vectorB.x - vectorA.x * vectorB.z;
   result.z = vectorA.x * vectorB.y - vectorA.y * vectorB.x;

   return result;
}


/////////////////////////////////////////////////////////////////
// This function returns the Dot Product of vectorA and VectorB.
GLfloat  UtilityVector3DotProduct(
   const UtilityVector3 vectorA, 
   const UtilityVector3 vectorB)
{
	return (vectorA.x * vectorB.x + 
      vectorA.y * vectorB.y + 
      vectorA.z * vectorB.z);
}


/////////////////////////////////////////////////////////////////
// This function returns a Unit Vector in the same direction as 
// the Cross Product of vectorA and VectorB.
UtilityVector3 UtilityNormalVector (
   const UtilityVector3 vectorA, 
   const UtilityVector3 vectorB)
{
   return UtilityVector3Normalize(
      UtilityVector3CrossProduct(vectorA, vectorB));
}


/////////////////////////////////////////////////////////////////
// This function returns YES if both p1 and p2 are on the same 
// side of the line defined by a and b.
GLboolean UtilityPointsAreOnSameSideOfLine(
   UtilityVector3 p1, 
   UtilityVector3 p2, 
   UtilityVector3 a, 
   UtilityVector3 b)
{
   UtilityVector3      cp1 = UtilityVector3CrossProduct(
      UtilityVector3Subtract(b, a), UtilityVector3Subtract(p1, a));
   UtilityVector3      cp2 = UtilityVector3CrossProduct(
      UtilityVector3Subtract(b, a), UtilityVector3Subtract(p2, a));
   
   return (0 <= UtilityVector3DotProduct(cp1, cp2));
}


/////////////////////////////////////////////////////////////////
// This function returns YES if p is inside the triangle formed
// by a, b, and c.
GLboolean UtilityPointIsInTriangle(
   UtilityVector3 p, 
   UtilityVector3 a, 
   UtilityVector3 b, 
   UtilityVector3 c)
{
   return (UtilityPointsAreOnSameSideOfLine(p, a, b, c) && 
           UtilityPointsAreOnSameSideOfLine(p, b, a, c) &&
           UtilityPointsAreOnSameSideOfLine(p, c, a, b));
}


/////////////////////////////////////////////////////////////////
// This function returns vectorA multiplied by the scalar
// scalefactor; The returned vector has changed magnitude but 
// the same direction as vectorA.
extern UtilityVector4 UtilityVector4Scale
(
 const UtilityVector4 vectorA, 
 const GLfloat scalefactor
)
{
   return UtilityVector4Make(
      vectorA.x * scalefactor, 
      vectorA.y * scalefactor,
      vectorA.z * scalefactor,
      vectorA.w * scalefactor);
}   
