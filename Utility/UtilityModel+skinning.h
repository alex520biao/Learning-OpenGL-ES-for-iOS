//
//  UtilityModel+skinning.h
//
//

#import "UtilityModel.h"

@interface UtilityModel (skinning)

- (void)assignJoint:(NSUInteger)anIndex;

- (void)automaticallySkinRigidWithJoints:(NSArray *)joints;
- (void)automaticallySkinSmoothWithJoints:(NSArray *)joints;

@end
