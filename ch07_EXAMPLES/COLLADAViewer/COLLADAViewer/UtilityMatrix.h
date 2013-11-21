//
//  UtilityMatrix.h
//  
//

#ifndef COLLADAViewer_UtilityMatrix_h
#define COLLADAViewer_UtilityMatrix_h

#ifdef __cplusplus
extern "C" {
#endif

#include "UtilityVector.h"
   
typedef union
{
   struct
   {
      float m00, m01, m02, m03;
      float m10, m11, m12, m13;
      float m20, m21, m22, m23;
      float m30, m31, m32, m33;
   };
   float m[16];
}
UtilityMatrix4;    

static UtilityMatrix4 UtilityMatrix4Identity = 
{
   1.0f, 0.0, 0.0, 0.0,
   0.0f, 1.0, 0.0, 0.0,
   0.0f, 0.0, 1.0, 0.0,
   0.0f, 0.0, 0.0, 1.0,
};


typedef union 
{
    struct
    {
        float m00, m01, m02;
        float m10, m11, m12;
        float m20, m21, m22;
    };
    float m[9];
}
UtilityMatrix3;


static UtilityMatrix3 UtilityMatrix3Identity = 
{
   1.0f, 0.0, 0.0,
   0.0f, 1.0, 0.0,
   0.0f, 0.0, 1.0,
};


static UtilityMatrix3 UtilityMatrix3MakeIdentity()
{
   return UtilityMatrix3Identity;
}


static UtilityVector3 UtilityMatrix3MultiplyVector3(
   UtilityMatrix3 matrixLeft, 
   UtilityVector3 vectorRight)
{
    UtilityVector3 v = { 
       matrixLeft.m[0] * vectorRight.v[0] + 
       matrixLeft.m[3] * vectorRight.v[1] + 
       matrixLeft.m[6] * vectorRight.v[2],
       matrixLeft.m[1] * vectorRight.v[0] + 
       matrixLeft.m[4] * vectorRight.v[1] + 
       matrixLeft.m[7] * vectorRight.v[2],
       matrixLeft.m[2] * vectorRight.v[0] + 
       matrixLeft.m[5] * vectorRight.v[1] + 
       matrixLeft.m[8] * vectorRight.v[2] };
       
    return v;
}


static UtilityMatrix3 UtilityMatrix4GetMatrix3(
   UtilityMatrix4 matrix)
{
    UtilityMatrix3 m = { 
       matrix.m[0], matrix.m[1], matrix.m[2],
       matrix.m[4], matrix.m[5], matrix.m[6],
       matrix.m[8], matrix.m[9], matrix.m[10] };
       
    return m;
}


static  UtilityMatrix3 
UtilityMatrix3MakeTranslation(float tx, float ty)
{
   UtilityMatrix3 m = UtilityMatrix3Identity;
   m.m[2] = tx;
   m.m[6] = ty;

   return m;
}


static  UtilityMatrix4 
UtilityMatrix4Make(float m00, float m01, float m02, float m03,
                 float m10, float m11, float m12, float m13,
                 float m20, float m21, float m22, float m23,
                 float m30, float m31, float m32, float m33);


static  UtilityMatrix4 
UtilityMatrix4MakeAndTranspose(float m00, float m01, float m02, float m03,
                             float m10, float m11, float m12, float m13,
                             float m20, float m21, float m22, float m23,
                             float m30, float m31, float m32, float m33);


static  UtilityMatrix4 
UtilityMatrix4MakeWithArray(float values[16]);


static  UtilityMatrix4 
UtilityMatrix4MakeWithArrayAndTranspose(float values[16]);


static  UtilityMatrix4 
UtilityMatrix4MakeWithRows(UtilityVector4 row0,
                         UtilityVector4 row1, 
                         UtilityVector4 row2,
                         UtilityVector4 row3);


static  UtilityMatrix4 
UtilityMatrix4MakeWithColumns(UtilityVector4 column0,
                            UtilityVector4 column1, 
                            UtilityVector4 column2,
                            UtilityVector4 column3);



static  UtilityMatrix4 
UtilityMatrix4MakeTranslation(float tx, float ty, float tz);


static  UtilityMatrix4 
UtilityMatrix4MakeScale(float sx, float sy, float sz);


static  UtilityMatrix4 
UtilityMatrix4MakeRotation(float radians, float x, float y, float z);


static  UtilityMatrix4 
UtilityMatrix4MakeXRotation(float radians);


static  UtilityMatrix4 
UtilityMatrix4MakeYRotation(float radians);


static  UtilityMatrix4 
UtilityMatrix4MakeZRotation(float radians);


static  UtilityMatrix4 
UtilityMatrix4MakePerspective(float fovyRadians, float aspect, float nearZ, float farZ);


static  UtilityMatrix4 
UtilityMatrix4MakeFrustum(float left, float right,
                        float bottom, float top,
                        float nearZ, float farZ);


static  UtilityMatrix4 
UtilityMatrix4MakeOrtho(float left, float right,
                      float bottom, float top,
                      float nearZ, float farZ);



static  UtilityVector4 
UtilityMatrix4GetRow(UtilityMatrix4 matrix, int row);


static  UtilityVector4 
UtilityMatrix4GetColumn(UtilityMatrix4 matrix, int column);


static  UtilityMatrix4 
UtilityMatrix4SetRow(UtilityMatrix4 matrix, int row, UtilityVector4 vector);


static  UtilityMatrix4 
UtilityMatrix4SetColumn(UtilityMatrix4 matrix, int column, UtilityVector4 vector);


static  UtilityMatrix4 
UtilityMatrix4Transpose(UtilityMatrix4 matrix);


static  UtilityMatrix4 
UtilityMatrix4Multiply(UtilityMatrix4 matrixLeft, UtilityMatrix4 matrixRight);


static  UtilityMatrix4 
UtilityMatrix4Add(UtilityMatrix4 matrixLeft, UtilityMatrix4 matrixRight);


static  UtilityMatrix4 
UtilityMatrix4Subtract(UtilityMatrix4 matrixLeft, UtilityMatrix4 matrixRight);


static  UtilityMatrix4 
UtilityMatrix4Translate(UtilityMatrix4 matrix, float tx, float ty, float tz);


static  UtilityMatrix4 
UtilityMatrix4TranslateWithVector3(UtilityMatrix4 matrix, UtilityVector3 translationVector);


static  UtilityMatrix4 
UtilityMatrix4TranslateWithVector4(UtilityMatrix4 matrix, UtilityVector4 translationVector);


static  UtilityMatrix4 
UtilityMatrix4Scale(UtilityMatrix4 matrix, float sx, float sy, float sz);


static  UtilityMatrix4 
UtilityMatrix4ScaleWithVector3(UtilityMatrix4 matrix, UtilityVector3 scaleVector);


static  UtilityMatrix4 
UtilityMatrix4ScaleWithVector4(UtilityMatrix4 matrix, UtilityVector4 scaleVector);


static  UtilityMatrix4 
UtilityMatrix4Rotate(UtilityMatrix4 matrix, float radians, float x, float y, float z);


static  UtilityMatrix4 
UtilityMatrix4RotateWithVector3(UtilityMatrix4 matrix, float radians, UtilityVector3 axisVector);


static  UtilityMatrix4 
UtilityMatrix4RotateWithVector4(UtilityMatrix4 matrix, float radians, UtilityVector4 axisVector);


static  UtilityMatrix4 
UtilityMatrix4RotateX(UtilityMatrix4 matrix, float radians);


static  UtilityMatrix4 
UtilityMatrix4RotateY(UtilityMatrix4 matrix, float radians);


static  UtilityMatrix4 
UtilityMatrix4RotateZ(UtilityMatrix4 matrix, float radians);


static  UtilityVector3 
UtilityMatrix4MultiplyVector3(UtilityMatrix4 matrixLeft, UtilityVector3 vectorRight);


static  UtilityVector3 
UtilityMatrix4MultiplyVector3WithTranslation(UtilityMatrix4 matrixLeft, UtilityVector3 vectorRight);


static  UtilityVector3 
UtilityMatrix4MultiplyAndProjectVector3(UtilityMatrix4 matrixLeft, UtilityVector3 vectorRight);


static  void 
UtilityMatrix4MultiplyVector3Array(UtilityMatrix4 matrix, UtilityVector3 *vectors, size_t vectorCount);


static  void 
UtilityMatrix4MultiplyVector3ArrayWithTranslation(UtilityMatrix4 matrix, UtilityVector3 *vectors, size_t vectorCount);


static  void 
UtilityMatrix4MultiplyAndProjectVector3Array(UtilityMatrix4 matrix, UtilityVector3 *vectors, size_t vectorCount);


static  UtilityVector4 
UtilityMatrix4MultiplyVector4(UtilityMatrix4 matrixLeft, UtilityVector4 vectorRight);

static  void 
UtilityMatrix4MultiplyVector4Array(UtilityMatrix4 matrix, UtilityVector4 *vectors, size_t vectorCount);

   
#pragma mark - Implementations
   
static  UtilityMatrix4 
UtilityMatrix4Make(float m00, float m01, float m02, float m03,
                 float m10, float m11, float m12, float m13,
                 float m20, float m21, float m22, float m23,
                 float m30, float m31, float m32, float m33)
{
   UtilityMatrix4 m = { m00, m01, m02, m03,
      m10, m11, m12, m13,
      m20, m21, m22, m23,
      m30, m31, m32, m33 };
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4MakeAndTranspose(float m00, float m01, float m02, float m03,
                             float m10, float m11, float m12, float m13,
                             float m20, float m21, float m22, float m23,
                             float m30, float m31, float m32, float m33)
{
   UtilityMatrix4 m = { m00, m10, m20, m30,
      m01, m11, m21, m31,
      m02, m12, m22, m32,
      m03, m13, m23, m33 };
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4MakeWithArray(float values[16])
{
   UtilityMatrix4 m = { values[0], values[1], values[2], values[3],
      values[4], values[5], values[6], values[7],
      values[8], values[9], values[10], values[11],
      values[12], values[13], values[14], values[15] };
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4MakeWithArrayAndTranspose(float values[16])
{
   UtilityMatrix4 m = { values[0], values[4], values[8], values[12],
      values[1], values[5], values[9], values[13],
      values[2], values[6], values[10], values[14],
      values[3], values[7], values[11], values[15] };
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4MakeWithRows(UtilityVector4 row0,
                         UtilityVector4 row1, 
                         UtilityVector4 row2,
                         UtilityVector4 row3)
{
   UtilityMatrix4 m = { row0.v[0], row1.v[0], row2.v[0], row3.v[0],
      row0.v[1], row1.v[1], row2.v[1], row3.v[1],
      row0.v[2], row1.v[2], row2.v[2], row3.v[2],
      row0.v[3], row1.v[3], row2.v[3], row3.v[3] };
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4MakeWithColumns(UtilityVector4 column0,
                            UtilityVector4 column1, 
                            UtilityVector4 column2,
                            UtilityVector4 column3)
{
   UtilityMatrix4 m = { column0.v[0], column0.v[1], column0.v[2], column0.v[3],
      column1.v[0], column1.v[1], column1.v[2], column1.v[3],
      column2.v[0], column2.v[1], column2.v[2], column2.v[3],
      column3.v[0], column3.v[1], column3.v[2], column3.v[3] };
   return m;
}


static  UtilityMatrix4 
UtilityMatrix4MakeTranslation(float tx, float ty, float tz)
{
   UtilityMatrix4 m = UtilityMatrix4Identity;
   m.m[12] = tx;
   m.m[13] = ty;
   m.m[14] = tz;
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4MakeScale(float sx, float sy, float sz)
{
   UtilityMatrix4 m = UtilityMatrix4Identity;
   m.m[0] = sx;
   m.m[5] = sy;
   m.m[10] = sz;
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4MakeRotation(float radians, float x, float y, float z)
{
   UtilityVector3 v = UtilityVector3Normalize(UtilityVector3Make(x, y, z));
   float cos = cosf(radians);
   float cosp = 1.0f - cos;
   float sin = sinf(radians);
   
   UtilityMatrix4 m = { cos + cosp * v.v[0] * v.v[0],
      cosp * v.v[0] * v.v[1] + v.v[2] * sin,
      cosp * v.v[0] * v.v[2] - v.v[1] * sin,
      0.0f,
      cosp * v.v[0] * v.v[1] - v.v[2] * sin,
      cos + cosp * v.v[1] * v.v[1],
      cosp * v.v[1] * v.v[2] + v.v[0] * sin,
      0.0f,
      cosp * v.v[0] * v.v[2] + v.v[1] * sin,
      cosp * v.v[1] * v.v[2] - v.v[0] * sin,
      cos + cosp * v.v[2] * v.v[2],
      0.0f,
      0.0f,
      0.0f,
      0.0f,
      1.0f };
   
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4MakeXRotation(float radians)
{
   float cos = cosf(radians);
   float sin = sinf(radians);
   
   UtilityMatrix4 m = { 1.0f, 0.0f, 0.0f, 0.0f,
      0.0f, cos, sin, 0.0f,
      0.0f, -sin, cos, 0.0f,
      0.0f, 0.0f, 0.0f, 1.0f };
   
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4MakeYRotation(float radians)
{
   float cos = cosf(radians);
   float sin = sinf(radians);
   
   UtilityMatrix4 m = { cos, 0.0f, -sin, 0.0f,
      0.0f, 1.0f, 0.0f, 0.0f,
      sin, 0.0f, cos, 0.0f,
      0.0f, 0.0f, 0.0f, 1.0f };
   
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4MakeZRotation(float radians)
{
   float cos = cosf(radians);
   float sin = sinf(radians);
   
   UtilityMatrix4 m = { cos, sin, 0.0f, 0.0f,
      -sin, cos, 0.0f, 0.0f,
      0.0f, 0.0f, 1.0f, 0.0f,
      0.0f, 0.0f, 0.0f, 1.0f };
   
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4MakePerspective(float fovyRadians, float aspect, float nearZ, float farZ)
{
   float cotan = 1.0f / tanf(fovyRadians / 2.0f);
   
   UtilityMatrix4 m = { cotan / aspect, 0.0f, 0.0f, 0.0f,
      0.0f, cotan, 0.0f, 0.0f,
      0.0f, 0.0f, (farZ + nearZ) / (nearZ - farZ), -1.0f,
      0.0f, 0.0f, (2.0f * farZ * nearZ) / (nearZ - farZ), 0.0f };
   
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4MakeFrustum(float left, float right,
                        float bottom, float top,
                        float nearZ, float farZ)
{
   float ral = right + left;
   float rsl = right - left;
   float tsb = top - bottom;
   float tab = top + bottom;
   float fan = farZ + nearZ;
   float fsn = farZ - nearZ;
   
   UtilityMatrix4 m = { 2.0f * nearZ / rsl, 0.0f, 0.0f, 0.0f,
      0.0f, 2.0f * nearZ / tsb, 0.0f, 0.0f,
      ral / rsl, tab / tsb, -fan / fsn, -1.0f,
      0.0f, 0.0f, (-2.0f * farZ * nearZ) / fsn, 0.0f };
   
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4MakeOrtho(float left, float right,
                      float bottom, float top,
                      float nearZ, float farZ)
{
   float ral = right + left;
   float rsl = right - left;
   float tab = top + bottom;
   float tsb = top - bottom;
   float fan = farZ + nearZ;
   float fsn = farZ - nearZ;
   
   UtilityMatrix4 m = { 2.0f / rsl, 0.0f, 0.0f, 0.0f,
      0.0f, 2.0f / tsb, 0.0f, 0.0f,
      0.0f, 0.0f, -2.0f / fsn, 0.0f,
      -ral / rsl, -tab / tsb, -fan / fsn, 1.0f };
   
   return m;
}


static  UtilityVector4 
UtilityMatrix4GetRow(UtilityMatrix4 matrix, int row)
{
   UtilityVector4 v = { matrix.m[row], matrix.m[4 + row], matrix.m[8 + row], matrix.m[12 + row] };
   return v;
}

static  UtilityVector4 
UtilityMatrix4GetColumn(UtilityMatrix4 matrix, int column)
{
   UtilityVector4 v = { matrix.m[column * 4 + 0], matrix.m[column * 4 + 1], matrix.m[column * 4 + 2], matrix.m[column * 4 + 3] };
   return v;
}

static  UtilityMatrix4 
UtilityMatrix4SetRow(UtilityMatrix4 matrix, int row, UtilityVector4 vector)
{
   matrix.m[row] = vector.v[0];
   matrix.m[row + 4] = vector.v[1];
   matrix.m[row + 8] = vector.v[2];
   matrix.m[row + 12] = vector.v[3];
   
   return matrix;
}

static  UtilityMatrix4 
UtilityMatrix4SetColumn(UtilityMatrix4 matrix, int column, UtilityVector4 vector)
{
   matrix.m[column * 4 + 0] = vector.v[0];
   matrix.m[column * 4 + 1] = vector.v[1];
   matrix.m[column * 4 + 2] = vector.v[2];
   matrix.m[column * 4 + 3] = vector.v[3];
   
   return matrix;
}

static  UtilityMatrix4 
UtilityMatrix4Transpose(UtilityMatrix4 matrix)
{
   UtilityMatrix4 m = { matrix.m[0], matrix.m[4], matrix.m[8], matrix.m[12],
      matrix.m[1], matrix.m[5], matrix.m[9], matrix.m[13],
      matrix.m[2], matrix.m[6], matrix.m[10], matrix.m[14],
      matrix.m[3], matrix.m[7], matrix.m[11], matrix.m[15] };
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4Multiply(UtilityMatrix4 matrixLeft, UtilityMatrix4 matrixRight)
{
   UtilityMatrix4 m;
   
   m.m[0]  = matrixLeft.m[0] * matrixRight.m[0]  + matrixLeft.m[4] * matrixRight.m[1]  + matrixLeft.m[8] * matrixRight.m[2]   + matrixLeft.m[12] * matrixRight.m[3];
   m.m[4]  = matrixLeft.m[0] * matrixRight.m[4]  + matrixLeft.m[4] * matrixRight.m[5]  + matrixLeft.m[8] * matrixRight.m[6]   + matrixLeft.m[12] * matrixRight.m[7];
   m.m[8]  = matrixLeft.m[0] * matrixRight.m[8]  + matrixLeft.m[4] * matrixRight.m[9]  + matrixLeft.m[8] * matrixRight.m[10]  + matrixLeft.m[12] * matrixRight.m[11];
   m.m[12] = matrixLeft.m[0] * matrixRight.m[12] + matrixLeft.m[4] * matrixRight.m[13] + matrixLeft.m[8] * matrixRight.m[14]  + matrixLeft.m[12] * matrixRight.m[15];
   
   m.m[1]  = matrixLeft.m[1] * matrixRight.m[0]  + matrixLeft.m[5] * matrixRight.m[1]  + matrixLeft.m[9] * matrixRight.m[2]   + matrixLeft.m[13] * matrixRight.m[3];
   m.m[5]  = matrixLeft.m[1] * matrixRight.m[4]  + matrixLeft.m[5] * matrixRight.m[5]  + matrixLeft.m[9] * matrixRight.m[6]   + matrixLeft.m[13] * matrixRight.m[7];
   m.m[9]  = matrixLeft.m[1] * matrixRight.m[8]  + matrixLeft.m[5] * matrixRight.m[9]  + matrixLeft.m[9] * matrixRight.m[10]  + matrixLeft.m[13] * matrixRight.m[11];
   m.m[13] = matrixLeft.m[1] * matrixRight.m[12] + matrixLeft.m[5] * matrixRight.m[13] + matrixLeft.m[9] * matrixRight.m[14]  + matrixLeft.m[13] * matrixRight.m[15];
   
   m.m[2]  = matrixLeft.m[2] * matrixRight.m[0]  + matrixLeft.m[6] * matrixRight.m[1]  + matrixLeft.m[10] * matrixRight.m[2]  + matrixLeft.m[14] * matrixRight.m[3];
   m.m[6]  = matrixLeft.m[2] * matrixRight.m[4]  + matrixLeft.m[6] * matrixRight.m[5]  + matrixLeft.m[10] * matrixRight.m[6]  + matrixLeft.m[14] * matrixRight.m[7];
   m.m[10] = matrixLeft.m[2] * matrixRight.m[8]  + matrixLeft.m[6] * matrixRight.m[9]  + matrixLeft.m[10] * matrixRight.m[10] + matrixLeft.m[14] * matrixRight.m[11];
   m.m[14] = matrixLeft.m[2] * matrixRight.m[12] + matrixLeft.m[6] * matrixRight.m[13] + matrixLeft.m[10] * matrixRight.m[14] + matrixLeft.m[14] * matrixRight.m[15];
   
   m.m[3]  = matrixLeft.m[3] * matrixRight.m[0]  + matrixLeft.m[7] * matrixRight.m[1]  + matrixLeft.m[11] * matrixRight.m[2]  + matrixLeft.m[15] * matrixRight.m[3];
   m.m[7]  = matrixLeft.m[3] * matrixRight.m[4]  + matrixLeft.m[7] * matrixRight.m[5]  + matrixLeft.m[11] * matrixRight.m[6]  + matrixLeft.m[15] * matrixRight.m[7];
   m.m[11] = matrixLeft.m[3] * matrixRight.m[8]  + matrixLeft.m[7] * matrixRight.m[9]  + matrixLeft.m[11] * matrixRight.m[10] + matrixLeft.m[15] * matrixRight.m[11];
   m.m[15] = matrixLeft.m[3] * matrixRight.m[12] + matrixLeft.m[7] * matrixRight.m[13] + matrixLeft.m[11] * matrixRight.m[14] + matrixLeft.m[15] * matrixRight.m[15];
   
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4Add(UtilityMatrix4 matrixLeft, UtilityMatrix4 matrixRight)
{
   UtilityMatrix4 m;
   
   m.m[0] = matrixLeft.m[0] + matrixRight.m[0];
   m.m[1] = matrixLeft.m[1] + matrixRight.m[1];
   m.m[2] = matrixLeft.m[2] + matrixRight.m[2];
   m.m[3] = matrixLeft.m[3] + matrixRight.m[3];
   
   m.m[4] = matrixLeft.m[4] + matrixRight.m[4];
   m.m[5] = matrixLeft.m[5] + matrixRight.m[5];
   m.m[6] = matrixLeft.m[6] + matrixRight.m[6];
   m.m[7] = matrixLeft.m[7] + matrixRight.m[7];
   
   m.m[8] = matrixLeft.m[8] + matrixRight.m[8];
   m.m[9] = matrixLeft.m[9] + matrixRight.m[9];
   m.m[10] = matrixLeft.m[10] + matrixRight.m[10];
   m.m[11] = matrixLeft.m[11] + matrixRight.m[11];
   
   m.m[12] = matrixLeft.m[12] + matrixRight.m[12];
   m.m[13] = matrixLeft.m[13] + matrixRight.m[13];
   m.m[14] = matrixLeft.m[14] + matrixRight.m[14];
   m.m[15] = matrixLeft.m[15] + matrixRight.m[15];
   
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4Subtract(UtilityMatrix4 matrixLeft, UtilityMatrix4 matrixRight)
{
   UtilityMatrix4 m;
   
   m.m[0] = matrixLeft.m[0] - matrixRight.m[0];
   m.m[1] = matrixLeft.m[1] - matrixRight.m[1];
   m.m[2] = matrixLeft.m[2] - matrixRight.m[2];
   m.m[3] = matrixLeft.m[3] - matrixRight.m[3];
   
   m.m[4] = matrixLeft.m[4] - matrixRight.m[4];
   m.m[5] = matrixLeft.m[5] - matrixRight.m[5];
   m.m[6] = matrixLeft.m[6] - matrixRight.m[6];
   m.m[7] = matrixLeft.m[7] - matrixRight.m[7];
   
   m.m[8] = matrixLeft.m[8] - matrixRight.m[8];
   m.m[9] = matrixLeft.m[9] - matrixRight.m[9];
   m.m[10] = matrixLeft.m[10] - matrixRight.m[10];
   m.m[11] = matrixLeft.m[11] - matrixRight.m[11];
   
   m.m[12] = matrixLeft.m[12] - matrixRight.m[12];
   m.m[13] = matrixLeft.m[13] - matrixRight.m[13];
   m.m[14] = matrixLeft.m[14] - matrixRight.m[14];
   m.m[15] = matrixLeft.m[15] - matrixRight.m[15];
   
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4Translate(UtilityMatrix4 matrix, float tx, float ty, float tz)
{
   UtilityMatrix4 m = { matrix.m[0], matrix.m[1], matrix.m[2], matrix.m[3],
      matrix.m[4], matrix.m[5], matrix.m[6], matrix.m[7],
      matrix.m[8], matrix.m[9], matrix.m[10], matrix.m[11],
      matrix.m[0] * tx + matrix.m[4] * ty + matrix.m[8] * tz + matrix.m[12],
      matrix.m[1] * tx + matrix.m[5] * ty + matrix.m[9] * tz + matrix.m[13],
      matrix.m[2] * tx + matrix.m[6] * ty + matrix.m[10] * tz + matrix.m[14],
      matrix.m[15] };
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4TranslateWithVector3(UtilityMatrix4 matrix, UtilityVector3 translationVector)
{
   UtilityMatrix4 m = { matrix.m[0], matrix.m[1], matrix.m[2], matrix.m[3],
      matrix.m[4], matrix.m[5], matrix.m[6], matrix.m[7],
      matrix.m[8], matrix.m[9], matrix.m[10], matrix.m[11],
      matrix.m[0] * translationVector.v[0] + matrix.m[4] * translationVector.v[1] + matrix.m[8] * translationVector.v[2] + matrix.m[12],
      matrix.m[1] * translationVector.v[0] + matrix.m[5] * translationVector.v[1] + matrix.m[9] * translationVector.v[2] + matrix.m[13],
      matrix.m[2] * translationVector.v[0] + matrix.m[6] * translationVector.v[1] + matrix.m[10] * translationVector.v[2] + matrix.m[14],
      matrix.m[15] };
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4TranslateWithVector4(UtilityMatrix4 matrix, UtilityVector4 translationVector)
{
   UtilityMatrix4 m = { matrix.m[0], matrix.m[1], matrix.m[2], matrix.m[3],
      matrix.m[4], matrix.m[5], matrix.m[6], matrix.m[7],
      matrix.m[8], matrix.m[9], matrix.m[10], matrix.m[11],
      matrix.m[0] * translationVector.v[0] + matrix.m[4] * translationVector.v[1] + matrix.m[8] * translationVector.v[2] + matrix.m[12],
      matrix.m[1] * translationVector.v[0] + matrix.m[5] * translationVector.v[1] + matrix.m[9] * translationVector.v[2] + matrix.m[13],
      matrix.m[2] * translationVector.v[0] + matrix.m[6] * translationVector.v[1] + matrix.m[10] * translationVector.v[2] + matrix.m[14],
      matrix.m[15] };
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4Scale(UtilityMatrix4 matrix, float sx, float sy, float sz)
{
   UtilityMatrix4 m = { matrix.m[0] * sx, matrix.m[1] * sx, matrix.m[2] * sx, matrix.m[3] * sx,
      matrix.m[4] * sy, matrix.m[5] * sy, matrix.m[6] * sy, matrix.m[7] * sy,
      matrix.m[8] * sz, matrix.m[9] * sz, matrix.m[10] * sz, matrix.m[11] * sz,
      matrix.m[12], matrix.m[13], matrix.m[14], matrix.m[15] };
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4ScaleWithVector3(UtilityMatrix4 matrix, UtilityVector3 scaleVector)
{
   UtilityMatrix4 m = { matrix.m[0] * scaleVector.v[0], matrix.m[1] * scaleVector.v[0], matrix.m[2] * scaleVector.v[0], matrix.m[3] * scaleVector.v[0],
      matrix.m[4] * scaleVector.v[1], matrix.m[5] * scaleVector.v[1], matrix.m[6] * scaleVector.v[1], matrix.m[7] * scaleVector.v[1],
      matrix.m[8] * scaleVector.v[2], matrix.m[9] * scaleVector.v[2], matrix.m[10] * scaleVector.v[2], matrix.m[11] * scaleVector.v[2],
      matrix.m[12], matrix.m[13], matrix.m[14], matrix.m[15] };
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4ScaleWithVector4(UtilityMatrix4 matrix, UtilityVector4 scaleVector)
{
   UtilityMatrix4 m = { matrix.m[0] * scaleVector.v[0], matrix.m[1] * scaleVector.v[0], matrix.m[2] * scaleVector.v[0], matrix.m[3] * scaleVector.v[0],
      matrix.m[4] * scaleVector.v[1], matrix.m[5] * scaleVector.v[1], matrix.m[6] * scaleVector.v[1], matrix.m[7] * scaleVector.v[1],
      matrix.m[8] * scaleVector.v[2], matrix.m[9] * scaleVector.v[2], matrix.m[10] * scaleVector.v[2], matrix.m[11] * scaleVector.v[2],
      matrix.m[12], matrix.m[13], matrix.m[14], matrix.m[15] };
   return m;
}

static  UtilityMatrix4 
UtilityMatrix4Rotate(UtilityMatrix4 matrix, float radians, float x, float y, float z)
{
   UtilityMatrix4 rm = 
   UtilityMatrix4MakeRotation(radians, x, y, z);
   return UtilityMatrix4Multiply(matrix, rm);
}

static  UtilityMatrix4 
UtilityMatrix4RotateWithVector3(UtilityMatrix4 matrix, float radians, UtilityVector3 axisVector)
{
   UtilityMatrix4 rm = UtilityMatrix4MakeRotation(radians, axisVector.v[0], axisVector.v[1], axisVector.v[2]);
   return UtilityMatrix4Multiply(matrix, rm);
}

static  UtilityMatrix4 
UtilityMatrix4RotateWithVector4(UtilityMatrix4 matrix, float radians, UtilityVector4 axisVector)
{
   UtilityMatrix4 rm = UtilityMatrix4MakeRotation(radians, axisVector.v[0], axisVector.v[1], axisVector.v[2]);
   return UtilityMatrix4Multiply(matrix, rm);    
}

static  UtilityMatrix4 
UtilityMatrix4RotateX(UtilityMatrix4 matrix, float radians)
{
   UtilityMatrix4 rm = UtilityMatrix4MakeXRotation(radians);
   return UtilityMatrix4Multiply(matrix, rm);
}

static  UtilityMatrix4 
UtilityMatrix4RotateY(UtilityMatrix4 matrix, float radians)
{
   UtilityMatrix4 rm = UtilityMatrix4MakeYRotation(radians);
   return UtilityMatrix4Multiply(matrix, rm);
}

static  UtilityMatrix4 
UtilityMatrix4RotateZ(UtilityMatrix4 matrix, float radians)
{
   UtilityMatrix4 rm = UtilityMatrix4MakeZRotation(radians);
   return UtilityMatrix4Multiply(matrix, rm);
}

static  UtilityVector4 
UtilityMatrix4MultiplyVector4(UtilityMatrix4 matrixLeft, UtilityVector4 vectorRight)
{
   UtilityVector4 v = { matrixLeft.m[0] * vectorRight.v[0] + matrixLeft.m[4] * vectorRight.v[1] + matrixLeft.m[8] * vectorRight.v[2] + matrixLeft.m[12] * vectorRight.v[3],
      matrixLeft.m[1] * vectorRight.v[0] + matrixLeft.m[5] * vectorRight.v[1] + matrixLeft.m[9] * vectorRight.v[2] + matrixLeft.m[13] * vectorRight.v[3],
      matrixLeft.m[2] * vectorRight.v[0] + matrixLeft.m[6] * vectorRight.v[1] + matrixLeft.m[10] * vectorRight.v[2] + matrixLeft.m[14] * vectorRight.v[3],
      matrixLeft.m[3] * vectorRight.v[0] + matrixLeft.m[7] * vectorRight.v[1] + matrixLeft.m[11] * vectorRight.v[2] + matrixLeft.m[15] * vectorRight.v[3] };
   return v;
}

static  void 
UtilityMatrix4MultiplyVector4Array(UtilityMatrix4 matrix, UtilityVector4 *vectors, size_t vectorCount)
{
   int i;
   for (i=0; i < vectorCount; i++)
      vectors[i] = UtilityMatrix4MultiplyVector4(matrix, vectors[i]);
}
   
static  UtilityVector3 
UtilityMatrix4MultiplyVector3(UtilityMatrix4 matrixLeft, UtilityVector3 vectorRight)
{
   UtilityVector4 v4 = UtilityMatrix4MultiplyVector4(matrixLeft, UtilityVector4Make(vectorRight.v[0], vectorRight.v[1], vectorRight.v[2], 0.0f));
   return UtilityVector3Make(v4.v[0], v4.v[1], v4.v[2]);
}

static  UtilityVector3 
UtilityMatrix4MultiplyVector3WithTranslation(UtilityMatrix4 matrixLeft, UtilityVector3 vectorRight)
{
   UtilityVector4 v4 = UtilityMatrix4MultiplyVector4(matrixLeft, UtilityVector4Make(vectorRight.v[0], vectorRight.v[1], vectorRight.v[2], 1.0f));
   return UtilityVector3Make(v4.v[0], v4.v[1], v4.v[2]);
}

static  UtilityVector3 
UtilityMatrix4MultiplyAndProjectVector3(UtilityMatrix4 matrixLeft, UtilityVector3 vectorRight)
{
   UtilityVector4 v4 = UtilityMatrix4MultiplyVector4(matrixLeft, UtilityVector4Make(vectorRight.v[0], vectorRight.v[1], vectorRight.v[2], 1.0f));
   return UtilityVector3Scale(UtilityVector3Make(v4.v[0], v4.v[1], v4.v[2]), 1.0f / v4.v[3]);
}

static  void 
UtilityMatrix4MultiplyVector3Array(UtilityMatrix4 matrix, UtilityVector3 *vectors, size_t vectorCount)
{
   int i;
   for (i=0; i < vectorCount; i++)
      vectors[i] = UtilityMatrix4MultiplyVector3(matrix, vectors[i]);
}

static  void 
UtilityMatrix4MultiplyVector3ArrayWithTranslation(UtilityMatrix4 matrix, UtilityVector3 *vectors, size_t vectorCount)
{
   int i;
   for (i=0; i < vectorCount; i++)
      vectors[i] = UtilityMatrix4MultiplyVector3WithTranslation(matrix, vectors[i]);
}

static  void 
UtilityMatrix4MultiplyAndProjectVector3Array(UtilityMatrix4 matrix, UtilityVector3 *vectors, size_t vectorCount)
{
   int i;
   for (i=0; i < vectorCount; i++)
      vectors[i] = UtilityMatrix4MultiplyAndProjectVector3(matrix, vectors[i]);
}

static UtilityMatrix4
UtilityMatrix4Invert(
   UtilityMatrix4 t, 
   BOOL *isInvertible)
{
    UtilityMatrix4 inverse = UtilityMatrix4Identity;
    
    float a0 = t.m[ 0]*t.m[ 5] - t.m[ 1]*t.m[ 4];
    float a1 = t.m[ 0]*t.m[ 6] - t.m[ 2]*t.m[ 4];
    float a2 = t.m[ 0]*t.m[ 7] - t.m[ 3]*t.m[ 4];
    float a3 = t.m[ 1]*t.m[ 6] - t.m[ 2]*t.m[ 5];
    float a4 = t.m[ 1]*t.m[ 7] - t.m[ 3]*t.m[ 5];
    float a5 = t.m[ 2]*t.m[ 7] - t.m[ 3]*t.m[ 6];
    float b0 = t.m[ 8]*t.m[13] - t.m[ 9]*t.m[12];
    float b1 = t.m[ 8]*t.m[14] - t.m[10]*t.m[12];
    float b2 = t.m[ 8]*t.m[15] - t.m[11]*t.m[12];
    float b3 = t.m[ 9]*t.m[14] - t.m[10]*t.m[13];
    float b4 = t.m[ 9]*t.m[15] - t.m[11]*t.m[13];
    float b5 = t.m[10]*t.m[15] - t.m[11]*t.m[14];

    float det = a0*b5 - a1*b4 + a2*b3 + a3*b2 - a4*b1 + a5*b0;
    BOOL canInvert = (fabs(det) > FLT_EPSILON);
    
    if (canInvert)
    {
        inverse.m[ 0] = + t.m[ 5]*b5 - t.m[ 6]*b4 + t.m[ 7]*b3;
        inverse.m[ 4] = - t.m[ 4]*b5 + t.m[ 6]*b2 - t.m[ 7]*b1;
        inverse.m[ 8] = + t.m[ 4]*b4 - t.m[ 5]*b2 + t.m[ 7]*b0;
        inverse.m[12] = - t.m[ 4]*b3 + t.m[ 5]*b1 - t.m[ 6]*b0;
        inverse.m[ 1] = - t.m[ 1]*b5 + t.m[ 2]*b4 - t.m[ 3]*b3;
        inverse.m[ 5] = + t.m[ 0]*b5 - t.m[ 2]*b2 + t.m[ 3]*b1;
        inverse.m[ 9] = - t.m[ 0]*b4 + t.m[ 1]*b2 - t.m[ 3]*b0;
        inverse.m[13] = + t.m[ 0]*b3 - t.m[ 1]*b1 + t.m[ 2]*b0;
        inverse.m[ 2] = + t.m[13]*a5 - t.m[14]*a4 + t.m[15]*a3;
        inverse.m[ 6] = - t.m[12]*a5 + t.m[14]*a2 - t.m[15]*a1;
        inverse.m[10] = + t.m[12]*a4 - t.m[13]*a2 + t.m[15]*a0;
        inverse.m[14] = - t.m[12]*a3 + t.m[13]*a1 - t.m[14]*a0;
        inverse.m[ 3] = - t.m[ 9]*a5 + t.m[10]*a4 - t.m[11]*a3;
        inverse.m[ 7] = + t.m[ 8]*a5 - t.m[10]*a2 + t.m[11]*a1;
        inverse.m[11] = - t.m[ 8]*a4 + t.m[ 9]*a2 - t.m[11]*a0;
        inverse.m[15] = + t.m[ 8]*a3 - t.m[ 9]*a1 + t.m[10]*a0;

        float invDet = ((float)1)/det;
        inverse.m[ 0] *= invDet;
        inverse.m[ 1] *= invDet;
        inverse.m[ 2] *= invDet;
        inverse.m[ 3] *= invDet;
        inverse.m[ 4] *= invDet;
        inverse.m[ 5] *= invDet;
        inverse.m[ 6] *= invDet;
        inverse.m[ 7] *= invDet;
        inverse.m[ 8] *= invDet;
        inverse.m[ 9] *= invDet;
        inverse.m[10] *= invDet;
        inverse.m[11] *= invDet;
        inverse.m[12] *= invDet;
        inverse.m[13] *= invDet;
        inverse.m[14] *= invDet;
        inverse.m[15] *= invDet;

    }
   
    if(NULL != isInvertible)
    {
       *isInvertible = canInvert;
    }
     
    return inverse;
}


#ifdef __cplusplus
}
#endif

#endif
