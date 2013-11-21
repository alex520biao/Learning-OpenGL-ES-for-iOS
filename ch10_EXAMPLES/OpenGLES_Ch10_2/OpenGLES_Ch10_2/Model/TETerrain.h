//
//  TETerrain.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TEModelPlacement;

@interface TETerrain : NSManagedObject

@property (nonatomic, retain) id detailTextureInfo0;
@property (nonatomic, retain) id detailTextureInfo1;
@property (nonatomic, retain) id detailTextureInfo2;
@property (nonatomic, retain) id detailTextureInfo3;
@property (nonatomic) float detailTextureScale0;
@property (nonatomic) float detailTextureScale1;
@property (nonatomic) float detailTextureScale2;
@property (nonatomic) float detailTextureScale3;
@property (nonatomic) int32_t glVertexAttributeBufferID;
@property (nonatomic) BOOL hasWater;
@property (nonatomic) float heightScaleFactor;
@property (nonatomic) int16_t length;
@property (nonatomic, retain) id lightAndWeightsTextureInfo;
@property (nonatomic) float lightDirectionX;
@property (nonatomic) float lightDirectionY;
@property (nonatomic) float lightDirectionZ;
@property (nonatomic) float metersPerUnit;
@property (nonatomic, retain) NSData * modelsData;
@property (nonatomic, retain) NSData * positionAttributesData;
@property (nonatomic) float waterHeight;
@property (nonatomic) int16_t width;
@property (nonatomic, retain) NSSet *modelPlacements;
@end

@interface TETerrain (CoreDataGeneratedAccessors)

- (void)addModelPlacementsObject:(TEModelPlacement *)value;
- (void)removeModelPlacementsObject:(TEModelPlacement *)value;
- (void)addModelPlacements:(NSSet *)values;
- (void)removeModelPlacements:(NSSet *)values;
@end
