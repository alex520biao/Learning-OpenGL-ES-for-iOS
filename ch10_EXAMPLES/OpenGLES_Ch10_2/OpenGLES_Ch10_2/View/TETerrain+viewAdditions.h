//
//  TETerrain+viewAdditions.h
//  TerrainEditor
//

#import "TETerrain+modelAdditions.h"
#import <GLKit/GLKit.h>

@class GLKTextureInfo;
@class UtilityCamera;
@class UtilityTerrainEffect;
@class UtilityPickTerrainEffect;
@class UtilityModelEffect;
@class UtilityModelManager;


/////////////////////////////////////////////////////////////////
// The only vertex attribute needed for terrain rendering is
// "position". 
typedef enum
{
   TETerrainPositionAttrib,
   TETerrainNumberOfAttributes
} TETerrainAttribute;


@interface TETerrain (viewAdditions) 

- (NSArray *)tiles;

- (void)prepareTerrainAttributes;

- (void)drawTerrainWithinFullDetailTiles:(NSArray *)fullDetailTiles 
   simplifiedTiles:(NSArray *)simplifiedTiles
   withCamera:(UtilityCamera *)aCamera
   terrainEffect:(UtilityTerrainEffect *)aTerrainEffect;

- (void)drawModelsWithinTiles:(NSArray *)tiles
   withCamera:(UtilityCamera *)aCamera
   modelEffect:(UtilityModelEffect *)aModelEffect
   modelManager:(UtilityModelManager *)modelManager;

- (void)identifyTilesToDraw:(NSArray *)someTiles
  withCamera:(UtilityCamera *)aCamera
  fullDetail:(NSMutableArray *)fullDetailTiles
  simplified:(NSMutableArray *)simplifiedTiles
  simplificationDistanceTiles:(GLfloat)aNumberOfTiles;

- (void)prepareToPickTerrain:(NSArray *)tiles 
   withCamera:(UtilityCamera *)aCamera
   pickEffect:(UtilityPickTerrainEffect *)aPickEffect;

@end
