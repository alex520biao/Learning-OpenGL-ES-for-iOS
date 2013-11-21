//
//  TETerrain+modelAdditions.h
//  TerrainEditor
//

#import "TETerrain.h"
#import "TEModelEffect.h"
#import "UtilityTextureLoader.h"
#import "UtilityVector.h"

@class TEHeightMap;

/////////////////////////////////////////////////////////////////
//  
typedef enum
{
   TETerrainPositionAttrib = TEModelPositionAttrib,
   TETerrainNumberOfAttributes = 2
} TETerrainAttribute;


@interface TETerrain (modelAdditions) 

- (void)updateWithHeightMap:(TEHeightMap *)aHeightMap
   metersPerUnit:(GLfloat)aNumber
   heightScaleFactor:(GLfloat)aFactor
   lightDirection:(UtilityVector3)aLightDirection
   inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSArray *)tiles;

- (void)prepareToDraw;
- (void)drawTiles:(NSArray *)tiles;
- (void)drawTileLines:(NSArray *)tiles;

- (NSData *)normalData;
- (UtilityTextureInfo *)defaultLightAndWeightsTextureInfo;
- (UtilityTextureInfo *)lightTexture;

- (void)adjustModelsToTerrain;

- (GLfloat)calculatedHeightAtXPos:(GLfloat)x zPos:(GLfloat)z;
- (GLfloat)heightAtXPos:(NSInteger)x zPos:(NSInteger)z;
- (GLfloat)maxHeightNearXPosMeters:(NSInteger)x 
   zPosMeters:(NSInteger)z;
- (GLfloat)regionalHeightAtXPos:(NSInteger)x zPos:(NSInteger)z;
- (GLfloat)smoothHeightNearXPos:(NSInteger)x 
   zPos:(NSInteger)z;
- (void)smoothTerrainAt:(UtilityVector2)aPosition
   radius:(GLfloat)aRadius;
- (void)updateTerrainWithHeightDelta:
   (float)delta 
   at:(UtilityVector2)aPosition
   radius:(GLfloat)aRadius;

- (BOOL)isHeightValidAtXPos:(NSInteger)x zPos:(NSInteger)z;

- (UtilityTextureInfo *)updatedLightInLightsAndWeightsTextureInfo;

- (GLfloat)widthMeters;
- (GLfloat)heightMeters;
- (GLfloat)lengthMeters;

@end
