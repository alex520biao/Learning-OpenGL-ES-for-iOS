//
//  AGLKFilters.h
//  
//

#import <GLKit/GLKit.h>

extern GLfloat AGLKScalarLowPassFilter(
   GLfloat fraction,          
   GLfloat target,            // target value to approach
   GLfloat current);          // current value

extern GLfloat AGLKScalarFastLowPassFilter(
   NSTimeInterval elapsed,    // seconds elapsed since last call
   GLfloat target,            // target value to approach
   GLfloat current);          // current value

extern GLfloat AGLKScalarSlowLowPassFilter(
   NSTimeInterval elapsed,    // seconds elapsed since last call
   GLfloat target,            // target value to approach
   GLfloat current);          // current value

extern GLKVector2 AGLKVector2LowPassFilter(
   GLfloat fraction,          
   GLKVector2 target,         // target value to approach
   GLKVector2 current);       // current value

extern GLKVector3 AGLKVector3LowPassFilter(
   GLfloat fraction,          
   GLKVector3 target,         // target value to approach
   GLKVector3 current);       // current value

extern GLKVector3 AGLKVector3FastLowPassFilter(
   NSTimeInterval elapsed,    // seconds elapsed since last call
   GLKVector3 target,         // target value to approach
   GLKVector3 current);       // current value

extern GLKVector3 AGLKVector3SlowLowPassFilter(
   NSTimeInterval elapsed,    // seconds elapsed since last call
   GLKVector3 target,         // target value to approach
   GLKVector3 current);       // current value
