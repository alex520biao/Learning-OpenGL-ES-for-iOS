//
//  TEModelPlacement.h
//  TerrainEditor
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TETerrain;

@interface TEModelPlacement : NSManagedObject

@property (nonatomic, retain) NSNumber * angle;
@property (nonatomic, retain) NSString * modelName;
@property (nonatomic, retain) NSNumber * positionX;
@property (nonatomic, retain) NSNumber * positionY;
@property (nonatomic, retain) NSNumber * positionZ;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) TETerrain *terrain;

@end
