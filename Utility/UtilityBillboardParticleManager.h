//
//  UtilityBillboardParticleManager.h
//
//

#import <GLKit/GLKit.h>
#import "AGLKFrustum.h"

@class UtilityBillboardParticle;
@class UtilityCamera;


@interface UtilityBillboardParticleManager : NSObject

@property (strong, nonatomic, readonly) 
    NSArray *sortedParticles;
@property (assign, nonatomic, readwrite) BOOL 
   shouldRenderSpherical;

- (void)updateWithElapsedTime:(NSTimeInterval)someSeconds
   frustum:(const AGLKFrustum *)frustumPtr;

- (void)addParticle:(UtilityBillboardParticle *)aParticle;

- (void)addParticleAtPosition:(GLKVector3)aPosition
   velocity:(GLKVector3)aVelocity
   force:(GLKVector3)aForce
   initialSize:(GLKVector2)anInitialSize
   finalSize:(GLKVector2)aFinalSize
   lifeSpanSeconds:(NSTimeInterval)aSpan
   fadeDurationSeconds:(NSTimeInterval)aDuration
   minTextureCoords:(GLKVector2)minCoords
   maxTextureCoords:(GLKVector2)maxCoords;


@end
