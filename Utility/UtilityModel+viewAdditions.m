//
//  UtilityModel+viewAdditions.m
// 
//

#import "UtilityModel+viewAdditions.h"
#import "UtilityMesh+viewAdditions.h"


@implementation UtilityModel (viewAdditions)

/////////////////////////////////////////////////////////////////
// This method draws the receiver using the receiver's
// UtilityMesh and a UtilityModelEffect that have both already 
// been prepared for drawing.
- (void)draw
{
   [self.mesh drawCommandsInRange:NSMakeRange(
      indexOfFirstCommand_, numberOfCommands_)];
}

@end
