//
//  UtilityMath.h
//  
//

#ifndef TEMath_H
#define TEMath_H

#ifdef __cplusplus
extern "C" {
#endif

#include "UtilityVector.h"

static const UtilityVector3 UtilityZeroVector = {0.0f, 0.0f, 0.0f};
static const float UtilityFloatEpsilon = (FLT_EPSILON);
static const float UtilityPI = (M_PI);
static const float Utility2PI = (M_PI * 2.0f);
static const float UtilityPI_OVER_2 = (M_PI / 2.0f);
static const float UtilityDegreesToRadians = (M_PI / 180.0f);
static const float UtilityRadiansToDegrees = (180.0f / M_PI);

#define UtilityFloatNotZero(a) (fabs(a) >= UtilityFloatEpsilon)

#ifdef __cplusplus
}
#endif

#endif // TEMath_H
