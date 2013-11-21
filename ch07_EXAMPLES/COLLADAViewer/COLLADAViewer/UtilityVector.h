//
//  UtilityVector.h
//  
//

#ifndef sceneVector_H
#define sceneVector_H

#include <math.h>
#include <float.h>
#include <OpenGL/gl.h>

#ifdef __cplusplus
extern "C" {
#endif

/////////////////////////////////////////////////////////////////
// This data type is used to store the  {X, Y} coordinates 
// for a vector.
typedef union 
{
   struct { float x, y; };
   struct { float r, g; };
   struct { float s, t; };
   float v[2];
}
UtilityVector2; 
   
/////////////////////////////////////////////////////////////////
// This data type is used to store the  {X, Y, Z} coordinates 
// for a vector.
typedef union 
{
   struct { float x, y, z; };
   struct { float r, g, b; };
   float v[3];
}
UtilityVector3; 
   
/////////////////////////////////////////////////////////////////
// This data type is used to store the  {X, Y, Z, W} coordinates 
// for a vector.
typedef union 
{
   struct { float x, y, z, w; };
   struct { float r, g, b, a; };
   float v[4];
}
UtilityVector4; 
   

/////////////////////////////////////////////////////////////////
// This data type is used to store the  {X, Y, Z} coordinates 
// for a position.
typedef UtilityVector3 UtilityPosition;


/////////////////////////////////////////////////////////////////
// This function returns an initialized vector.
extern UtilityVector3 UtilityVector3MakeWithArray
(
 const GLfloat v[3]
 );

/////////////////////////////////////////////////////////////////
// This function returns an initialized vector.
extern UtilityVector3 UtilityVector3Make
(
 const GLfloat x, 
 const GLfloat y,
 const GLfloat z
 );

/////////////////////////////////////////////////////////////////
// This function returns the vector sum of vectorA and vectorB.
extern UtilityVector3 UtilityVector3Add
(
 const UtilityVector3 vectorA, 
 const UtilityVector3 vectorB
 );   

/////////////////////////////////////////////////////////////////
// This function returns positionA minus positionB.
extern UtilityVector2 UtilityVector2Subtract
(
 const UtilityVector2 positionA, 
 const UtilityVector2 positionB
 );


/////////////////////////////////////////////////////////////////
// This function returns the length squared a.k.a. magnitude of 
// vectorA squared.
extern GLfloat UtilityVector2LengthSquared
(
 const UtilityVector2 vectorA
 );

/////////////////////////////////////////////////////////////////
// This function returns the distance and direction 
// from positionA to positionB.
extern UtilityVector3 UtilityVector3FromPositionToPosition
(
 const UtilityPosition positionA, 
 const UtilityPosition positionB
 );


/////////////////////////////////////////////////////////////////
// This function returns vectorA multiplied by the scalar
// scalefactor; The returned vector has changed magnitude but 
// the same direction as vectorA.
extern UtilityVector3 UtilityVector3Scale
(
 const UtilityVector3 vectorA, 
 const GLfloat scalefactor
 );   

/////////////////////////////////////////////////////////////////
// This function returns the length squared a.k.a. magnitude of 
// vectorA squared.
extern GLfloat UtilityVector3LengthSquared
(
 const UtilityVector3 vectorA
 );

/////////////////////////////////////////////////////////////////
// This function returns the length a.k.a. magnitude of vectorA.
extern GLfloat UtilityVector3Length
(
 const UtilityVector3 vectorA
 );

/////////////////////////////////////////////////////////////////
// This function returns a Unit Vector with the same direction as
// vectorA
extern UtilityVector3 UtilityVector3Normalize
(
 UtilityVector3 vectorA
 );

/////////////////////////////////////////////////////////////////
// This function returns the Cross Product vectorA x VectorB.
extern UtilityVector3 UtilityVector3CrossProduct
(
 const UtilityVector3 vectorA, 
 const UtilityVector3 vectorB
 );

/////////////////////////////////////////////////////////////////
// This function returns the Dot Product of vectorA and VectorB.
GLfloat  UtilityVector3DotProduct
(
 const UtilityVector3 vectorA, 
 const UtilityVector3 vectorB
 );


/////////////////////////////////////////////////////////////////
// This function returns a Unit Vector in the same direction as 
// the Cross Product of vectorA and VectorB.
extern UtilityVector3 UtilityNormalVector
(
 const UtilityVector3 vectorA, 
 const UtilityVector3 vectorB
 );


/////////////////////////////////////////////////////////////////
// This function returns an initialized vector.
extern UtilityVector4 UtilityVector4MakeWithArray
(
 const GLfloat v[4]
 );

/////////////////////////////////////////////////////////////////
// This function returns an initialized vector.
extern UtilityVector4 UtilityVector4Make
(
 const GLfloat x, 
 const GLfloat y,
 const GLfloat z,
 const GLfloat w
 );


#ifdef __cplusplus
}
#endif

#endif  // sceneVector_H
