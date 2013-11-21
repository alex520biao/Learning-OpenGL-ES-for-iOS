//
//  UtilityModelManager+skinning.m
//
//

#import "UtilityModelManager+skinning.h"
#import "UtilityMesh+skinning.h"


@implementation UtilityModelManager (skinning)

/////////////////////////////////////////////////////////////////
// 
- (void)prepareToDrawWithJointInfluence;
{
   [self.consolidatedMesh prepareToDrawWithJointInfluence];
}

@end
