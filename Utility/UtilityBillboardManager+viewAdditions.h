//
//  UtilityBillboardManager+viewAdditions.h
//  
//

#import "UtilityBillboardManager.h"

@interface UtilityBillboardManager (viewAdditions)

- (void)drawWithEyePosition:(GLKVector3)eyePosition 
   lookDirection:(GLKVector3)lookDirection 
   upVector:(GLKVector3)upVector;

@end
