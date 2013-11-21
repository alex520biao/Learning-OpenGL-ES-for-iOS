//
//  TECart+viewAdditions.m
//  OpenGLES_Ch12_1
//

#import "TECart+viewAdditions.h"
#import "TEParticleEmitter.h"
#import "UtilityModelEffect.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityBillboardParticleManager.h"


@implementation TECart (viewAdditions)

/////////////////////////////////////////////////////////////////
// Draw the receiver using anEffect.
- (void)drawWithEffect:(UtilityModelEffect *)anEffect;
{
   GLKVector3 position = self.position;
   
   // Move cart to position
   anEffect.modelviewMatrix = GLKMatrix4Translate(
      anEffect.modelviewMatrix, 
      position.x, 
      position.y, 
      position.z);

   // Transform to cart's orientation
   anEffect.modelviewMatrix = GLKMatrix4Multiply(
      anEffect.modelviewMatrix,
      GLKMatrix4Transpose(self.orientationMatrix));
   
   [anEffect prepareModelview];
        
   [self.model draw];
}

@end
