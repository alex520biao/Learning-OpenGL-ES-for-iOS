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

- (void)drawTerrainWithinTiles:(NSArray *)tiles 
   withCamera:(UtilityCamera *)aCamera
   terrainEffect:(UtilityTerrainEffect *)aTerrainEffect;

- (void)drawModelsWithinTiles:(NSArray *)tiles
   withCamera:(UtilityCamera *)aCamera
   modelEffect:(UtilityModelEffect *)aModelEffect
   modelManager:(UtilityModelManager *)modelManager;

- (void)prepareToPickTerrain:(NSArray *)tiles 
   withCamera:(UtilityCamera *)aCamera
   pickEffect:(UtilityPickTerrainEffect *)aPickEffect;

@end
