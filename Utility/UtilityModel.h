//
//  UtilityModel.h
// 
//

#import <GLKit/GLKit.h>
#import "AGLKAxisAllignedBoundingBox.h"

@class UtilityMesh;


@interface UtilityModel : NSObject
{
   NSUInteger indexOfFirstCommand_;
   NSUInteger numberOfCommands_;
}

@property (copy, nonatomic, readonly) NSString
   *name;
@property (strong, nonatomic, readonly) UtilityMesh
   *mesh;
@property (assign, nonatomic, readonly) NSUInteger
   indexOfFirstCommand;
@property (assign, nonatomic, readonly) NSUInteger
   numberOfCommands;
@property (assign, nonatomic, readonly) 
   AGLKAxisAllignedBoundingBox axisAlignedBoundingBox;
@property (assign, nonatomic, readonly) 
   BOOL doesRequireLighting;
   
- (id)initWithName:(NSString *)aName 
   mesh:(UtilityMesh *)aMesh
   indexOfFirstCommand:(NSUInteger)aFirstIndex
   numberOfCommands:(NSUInteger)count
   axisAlignedBoundingBox:(AGLKAxisAllignedBoundingBox)
      aBoundingBox;
      
- (id)initWithPlistRepresentation:(NSDictionary *)aDictionary
   mesh:(UtilityMesh *)aMesh;

@end

/////////////////////////////////////////////////////////////////
// Constants used to access model properties from a plist
// dictionary.
extern NSString *const UtilityModelName;
extern NSString *const UtilityModelIndexOfFirstCommand;
extern NSString *const UtilityModelNumberOfCommands;
extern NSString *const UtilityModelAxisAlignedBoundingBox;
extern NSString *const UtilityModelDrawingCommand; 
