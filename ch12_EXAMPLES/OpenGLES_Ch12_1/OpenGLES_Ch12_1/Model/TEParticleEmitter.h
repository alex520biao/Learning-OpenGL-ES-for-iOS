//
//  TEParticleEmitter.h
//  OpenGLES_Ch12_1
//

#import <GLKit/GLKit.h>

@class UtilityModel;
@class UtilityBillboardParticleManager;


/////////////////////////////////////////////////////////////////
// Type for blocks called to emit particles
typedef void (^TEParticleEmitterBlock)(
   GLKVector3 position,
   UtilityBillboardParticleManager *manager,
   NSTimeInterval elapsedTime,
   id owner);


@interface TEParticleEmitter : NSObject

@property (assign, nonatomic, readonly) 
   GLKVector3 position; 

- (id)initWithModel:(UtilityModel *)aModel;

- (void)updateWithParticleEmitterBlock:
      (TEParticleEmitterBlock)aBlock
   manager:(UtilityBillboardParticleManager *)manager
   elapsedTime:(NSTimeInterval)someSeconds
   owner:(id)anOwner;

@end
