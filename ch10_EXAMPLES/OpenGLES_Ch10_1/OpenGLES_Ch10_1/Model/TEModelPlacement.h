//
//  TEModelPlacement.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TETerrain;

@interface TEModelPlacement : NSManagedObject

@property (nonatomic) float angle;
@property (nonatomic) int32_t index;
@property (nonatomic, retain) NSString * modelName;
@property (nonatomic) float positionX;
@property (nonatomic) float positionY;
@property (nonatomic) float positionZ;
@property (nonatomic, retain) TETerrain *terrain;

@end
