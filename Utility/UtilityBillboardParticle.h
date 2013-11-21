//
//  UtilityBillboardParticle.h
//  
//

#import <GLKit/GLKit.h>
#import "AGLKFrustum.h"


@interface UtilityBillboardParticle : NSObject

@property (assign, nonatomic, readonly) 
   GLKVector3 position;
@property (assign, nonatomic, readonly) 
   GLKVector3 velocity;
@property (assign, nonatomic, readonly) 
   GLKVector3 force;
@property (assign, nonatomic, readonly) 
   GLKVector2 initialSize;
@property (assign, nonatomic, readonly) 
   GLKVector2 finalSize;
@property (assign, nonatomic, readonly) 
   NSTimeInterval lifeSpan;
@property (assign, nonatomic, readonly) 
   NSTimeInterval fadeDurationSeconds;
@property (assign, nonatomic, readonly) 
   GLKVector2 minTextureCoords;
@property (assign, nonatomic, readonly) 
   GLKVector2 maxTextureCoords;
@property (assign, nonatomic, readonly) 
   GLfloat distanceSquared;

@property (assign, nonatomic, readonly) 
   BOOL isAlive;
@property (assign, nonatomic, readonly) 
   NSTimeInterval lifeRemainingSeconds;
@property (assign, nonatomic, readonly) 
   GLKVector2 size;
@property (assign, nonatomic, readonly) 
   GLfloat opacity;

- (id)initWithPosition:(GLKVector3)aPosition
   velocity:(GLKVector3)aVelocity
   force:(GLKVector3)aForce
   initialSize:(GLKVector2)anInitialSize
   finalSize:(GLKVector2)aFinalSize
   lifeSpanSeconds:(NSTimeInterval)aSpan
   fadeDurationSeconds:(NSTimeInterval)aDuration
   minTextureCoords:(GLKVector2)minCoords
   maxTextureCoords:(GLKVector2)maxCoords;

- (void)updateWithElapsedTime:(NSTimeInterval)someSeconds
   frustum:(const AGLKFrustum *)frustumPtr;

@end

// Function used to sort particles by distance
extern NSComparisonResult AGLKCompareBillboardParticleDistance(
  UtilityBillboardParticle *a, 
  UtilityBillboardParticle *b, 
  void *context);