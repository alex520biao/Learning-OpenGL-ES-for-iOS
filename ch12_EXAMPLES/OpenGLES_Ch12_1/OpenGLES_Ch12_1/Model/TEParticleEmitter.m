//
//  TEParticleEmitter.m
//  OpenGLES_Ch12_1
//

#import "TEParticleEmitter.h"
#import "UtilityModel.h"
#import "AGLKFilters.h"
#import "AGLKAxisAllignedBoundingBox.h"


@implementation TEParticleEmitter

@synthesize position = position_;


/////////////////////////////////////////////////////////////////
// designated initializer
- (id)initWithModel:(UtilityModel *)aModel;
{
   if(nil != (self = [super init]))
   {
      AGLKAxisAllignedBoundingBox  particleEmitterBox =
         aModel.axisAlignedBoundingBox;
      position_ = AGLKVector3LowPassFilter(
         0.5f,
         particleEmitterBox.min,
         particleEmitterBox.max);
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
// This method invokes aBlock passing receiver's position along
// with manager along with someSeconds and owner.
- (void)updateWithParticleEmitterBlock:
      (TEParticleEmitterBlock)aBlock
   manager:(UtilityBillboardParticleManager *)manager
   elapsedTime:(NSTimeInterval)someSeconds
   owner:(id)owner;
{
   aBlock(self.position, 
      manager, 
      someSeconds, 
      owner);
}

@end
