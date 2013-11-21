//
//  TETerrain.h
//  TerrainEditor
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TEModelPlacement;

@interface TETerrain : NSManagedObject

@property (nonatomic, retain) id detailTextureInfo0;
@property (nonatomic, retain) id detailTextureInfo1;
@property (nonatomic, retain) id detailTextureInfo2;
@property (nonatomic, retain) id detailTextureInfo3;
@property (nonatomic, retain) NSNumber * detailTextureScale0;
@property (nonatomic, retain) NSNumber * detailTextureScale1;
@property (nonatomic, retain) NSNumber * detailTextureScale2;
@property (nonatomic, retain) NSNumber * detailTextureScale3;
@property (nonatomic, retain) NSNumber * glVertexAttributeBufferID;
@property (nonatomic, retain) NSNumber * hasWater;
@property (nonatomic, retain) NSNumber * heightScaleFactor;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) id lightAndWeightsTextureInfo;
@property (nonatomic, retain) NSNumber * lightDirectionX;
@property (nonatomic, retain) NSNumber * lightDirectionY;
@property (nonatomic, retain) NSNumber * lightDirectionZ;
@property (nonatomic, retain) NSNumber * metersPerUnit;
@property (nonatomic, retain) NSData * modelsData;
@property (nonatomic, retain) NSData * positionAttributesData;
@property (nonatomic, retain) NSNumber * waterHeight;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSSet *modelPlacements;
@end

@interface TETerrain (CoreDataGeneratedAccessors)

- (void)addModelPlacementsObject:(TEModelPlacement *)value;
- (void)removeModelPlacementsObject:(TEModelPlacement *)value;
- (void)addModelPlacements:(NSSet *)values;
- (void)removeModelPlacements:(NSSet *)values;
@end
