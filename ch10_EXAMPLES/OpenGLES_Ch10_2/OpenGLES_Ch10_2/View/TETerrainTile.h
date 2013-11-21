//
//  TETerrainTile.h
//  TerrainViewer
//

#import <Foundation/Foundation.h>

@class TETerrain;


@interface TETerrainTile : NSObject

@property (assign, nonatomic, readonly) NSInteger originX;
@property (assign, nonatomic, readonly) NSInteger originY;
@property (strong, nonatomic, readonly) NSSet *
   containedModelPlacements;

- (id)initWithTerrain:(TETerrain *)aTerrain
   tileOriginX:(NSInteger)x 
   tileOriginY:(NSInteger)y 
   tileWidth:(NSInteger)aWidth
   tileLength:(NSInteger)aLength;
   
- (void)draw;
- (void)drawSimplified;

- (void)manageContainedModelPlacements:(NSSet *)somePlacements;
- (NSSet *)containedModelPlacements;

@end

static const NSInteger TETerrainTileDefaultWidth = 32;
static const NSInteger TETerrainTileDefaultLength = 32;
