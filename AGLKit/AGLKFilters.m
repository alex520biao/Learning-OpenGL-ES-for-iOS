//
//  AGLKFilters.m
//  
//

#import "AGLKFilters.h"

/////////////////////////////////////////////////////////////////
// 
GLfloat AGLKScalarLowPassFilter(
   GLfloat fraction,          
   GLfloat target,            // target value to approach
   GLfloat current)           // current value
{
   return current + (fraction * (target - current));
}


/////////////////////////////////////////////////////////////////
// This function returns a value between target and current. Call
// this function repeatedly to asymptotically return values closer
// to target: "ease in" to the target value.
GLfloat AGLKScalarFastLowPassFilter(
   NSTimeInterval elapsed,    // seconds elapsed since last call
   GLfloat target,            // target value to approach
   GLfloat current)           // current value
{  // Constant 50.0 is an arbitrarily "large" factor
   return AGLKScalarLowPassFilter(MIN(50.0 * elapsed, 1.0f),
      target, current);
}


/////////////////////////////////////////////////////////////////
// This function returns a value between target and current. Call
// this function repeatedly to asymptotically return values closer
// to target: "ease in" to the target value.
GLfloat AGLKScalarSlowLowPassFilter(
   NSTimeInterval elapsed,    // seconds elapsed since last call
   GLfloat target,            // target value to approach
   GLfloat current)           // current value
{  // Constant 4.0 is an arbitrarily "small" factor
   return AGLKScalarLowPassFilter(MIN(4.0 * elapsed, 1.0f),
      target, current);
}


/////////////////////////////////////////////////////////////////
// 
GLKVector2 AGLKVector2LowPassFilter(
   GLfloat fraction,          
   GLKVector2 target,         // target value to approach
   GLKVector2 current)        // current value
{
   return GLKVector2Make(
      AGLKScalarLowPassFilter(fraction, target.x, current.x),
      AGLKScalarLowPassFilter(fraction, target.y, current.y));
}


/////////////////////////////////////////////////////////////////
// 
GLKVector3 AGLKVector3LowPassFilter(
   GLfloat fraction,          
   GLKVector3 target,         // target value to approach
   GLKVector3 current)        // current value
{
   return GLKVector3Make(
      AGLKScalarLowPassFilter(fraction, target.x, current.x),
      AGLKScalarLowPassFilter(fraction, target.y, current.y),
      AGLKScalarLowPassFilter(fraction, target.z, current.z));
}


/////////////////////////////////////////////////////////////////
// This function returns a vector between target and current. 
// Call repeatedly to asymptotically return vectors closer
// to target: "ease in" to the target value.
GLKVector3 AGLKVector3FastLowPassFilter(
   NSTimeInterval elapsed,    // seconds elapsed since last call
   GLKVector3 target,         // target value to approach
   GLKVector3 current)        // current value
{  
   return GLKVector3Make(
      AGLKScalarFastLowPassFilter(elapsed, target.x, current.x),
      AGLKScalarFastLowPassFilter(elapsed, target.y, current.y),
      AGLKScalarFastLowPassFilter(elapsed, target.z, current.z));
}


/////////////////////////////////////////////////////////////////
// This function returns a vector between target and current. 
// Call repeatedly to asymptotically return vectors closer
// to target: "ease in" to the target value.
GLKVector3 AGLKVector3SlowLowPassFilter(
   NSTimeInterval elapsed,    // seconds elapsed since last call
   GLKVector3 target,         // target value to approach
   GLKVector3 current)        // current value
{  
   return GLKVector3Make(
      AGLKScalarSlowLowPassFilter(elapsed, target.x, current.x),
      AGLKScalarSlowLowPassFilter(elapsed, target.y, current.y),
      AGLKScalarSlowLowPassFilter(elapsed, target.z, current.z));
}
