//
//  UtilityBillboardParticle.m
//  
//

#import "UtilityBillboardParticle.h"
#import "AGLKFilters.h"

@interface UtilityBillboardParticle ()

@property (assign, nonatomic, readwrite) 
   GLKVector3 position;
@property (assign, nonatomic, readwrite) 
   GLKVector3 velocity;
@property (assign, nonatomic, readwrite) 
   NSTimeInterval lifeRemainingSeconds;

@end


@implementation UtilityBillboardParticle

@synthesize position = position_;
@synthesize velocity = velocity_;
@synthesize force = force_;
@synthesize initialSize = initialSize_;
@synthesize finalSize = finalSize_;
@synthesize lifeSpan = lifeSpan_;
@synthesize lifeRemainingSeconds = lifeRemainingSeconds_;
@synthesize fadeDurationSeconds = fadeDurationSeconds_;
@synthesize minTextureCoords = minTextureCoords_;
@synthesize maxTextureCoords = maxTextureCoords_;
@synthesize isAlive = isAlive_;
@synthesize distanceSquared = distanceSquared_;


/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)initWithPosition:(GLKVector3)aPosition
   velocity:(GLKVector3)aVelocity
   force:(GLKVector3)aForce
   initialSize:(GLKVector2)anInitialSize
   finalSize:(GLKVector2)aFinalSize
   lifeSpanSeconds:(NSTimeInterval)aSpan
   fadeDurationSeconds:(NSTimeInterval)aDuration
   minTextureCoords:(GLKVector2)minCoords
   maxTextureCoords:(GLKVector2)maxCoords;
{
   if(nil != (self = [super init]))
   {
      position_ = aPosition;
      velocity_ = aVelocity;
      force_ = aForce;
      initialSize_ = anInitialSize;
      finalSize_ = aFinalSize;
      lifeSpan_ = aSpan;
      lifeRemainingSeconds_ = aSpan;
      fadeDurationSeconds_ = aDuration;
      minTextureCoords_ = minCoords;
      maxTextureCoords_ = maxCoords;
      isAlive_ = (0.0 < self.lifeRemainingSeconds);        
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// override of inherited initializer
- (id)init
{
   NSAssert(0, @"Invalid initializer");
   
   return nil;
}


/////////////////////////////////////////////////////////////////
// Apply Newtonian physics and filters to modify the receiver's
// position and velocity.
- (void)updateWithElapsedTime:(NSTimeInterval)someSeconds
   frustum:(const AGLKFrustum *)frustumPtr;
{
   if(isAlive_)
   {
      lifeRemainingSeconds_ -= someSeconds;

      // Mass is assumed to be 1.0, so acceleration = force (a = f/m)
      // v = v0 + at : v is new velocity; v0 is initial velocity;
      //               a is acceleration; t is elapsed time
      GLKVector3 newVelocity = GLKVector3Add(
         velocity_,
         GLKVector3MultiplyScalar(
            force_, 
            someSeconds));
      
      // Calculate new position based on newVelocity
      // s = s0 + 0.5 * (v0 + v) * t : s is new position; 
      //                              s0 is initial position;
      //                              v0 is initial velocity; 
      //                              v is new velocity;
      //                              t is elapsed time
      position_ = GLKVector3Add(position_,
         GLKVector3MultiplyScalar(
            GLKVector3Add(velocity_, newVelocity), 
            0.5f * someSeconds));
            
      velocity_ = newVelocity;
      isAlive_ = (0.0 < lifeRemainingSeconds_);        
      
      const GLKVector3 vectorFromEye = GLKVector3Subtract(
         position_, frustumPtr->eyePosition);
      distanceSquared_ = GLKVector3DotProduct(vectorFromEye, 
         frustumPtr->zUnitVector);
   }
}


/////////////////////////////////////////////////////////////////
// Returns YES if the receiver's life remaining seconds are 
// greater than zero. Returns NO otherwise. Dead particles 
// should not be drawn and may safely be reused at new
// positions, sizes, etc.
- (BOOL)isAlive
{
   return isAlive_;
}


/////////////////////////////////////////////////////////////////
// Returns the receiver's size using time based filters to
// interpolate between the receiver's initial size and its final 
// size.
- (GLKVector2)size;
{
   GLKVector2 result = finalSize_;
   
   if(0.0f < lifeSpan_ && isAlive_)
   {
      const GLfloat fractionRemaining = lifeRemainingSeconds_ /
         lifeSpan_; 
         
      result = AGLKVector2LowPassFilter(
         1.0f - fractionRemaining,          
         result,
         initialSize_);
   }
   
   return result;
}


/////////////////////////////////////////////////////////////////
// Returns the receiver's opacity using time based filters to
// interpolate between 1.0 and its final opacity. Note: if the
// receiver's fadeDurationSeconds property is initialized to be 
// greater than the receiver's lifeRemainingSeconds, the 
// billboard will be drawn translucent from the start of its
// life.
- (GLfloat)opacity;
{
   GLfloat result = 1.0f;
   const GLfloat fadeFraction = (fadeDurationSeconds_ - 
      lifeRemainingSeconds_) / fadeDurationSeconds_;
       
   if(0.0f < fadeFraction)
   {
      result = AGLKScalarLowPassFilter(
         fadeFraction,
         0.0f,
         result);
   }
   
   return result;
}


/////////////////////////////////////////////////////////////////
// Function used to compare particles when sorting.
NSComparisonResult AGLKCompareBillboardParticleDistance(
  UtilityBillboardParticle *a, 
  UtilityBillboardParticle *b, 
  void *context)
{
   NSInteger result = NSOrderedSame;
   
   if(!a->isAlive_ && b->isAlive_)
   {  // A live billboard is always ordered after a dead one
      result = NSOrderedAscending;
   }
   else if(a->isAlive_ && !b->isAlive_)
   {  // A live billboard is always ordered after a dead one
      result = NSOrderedDescending;
   }
   else if (a->distanceSquared_ < b->distanceSquared_)
   {  // Distant particles are ordered after near ones
      result = NSOrderedDescending;
   }
   else if (a->distanceSquared_ > b->distanceSquared_)
   {  // Distant particles are ordered after near ones
      result = NSOrderedAscending;
   }
   
   return result;
}

@end
