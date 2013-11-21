//
//  TETerrainEffect.h
//  TerrainViewer
//

#import "TEEffect.h"
#import "TEHeightMap.h"
#import "UtilityMatrix.h"

@class TETerrain;
@class UtilityTextureInfo;


@interface TETerrainEffect : TEEffect

@property (assign, nonatomic, readwrite) UtilityVector4 globalAmbientLightColor;
@property (assign, nonatomic, readwrite) UtilityMatrix4 projectionMatrix;
@property (assign, nonatomic, readwrite) UtilityMatrix4 modelviewMatrix;
@property (assign, nonatomic, readwrite) UtilityMatrix3 textureMatrix0;
@property (assign, nonatomic, readwrite) UtilityMatrix3 textureMatrix1;
@property (assign, nonatomic, readwrite) UtilityMatrix3 textureMatrix2;
@property (assign, nonatomic, readwrite) UtilityMatrix3 textureMatrix3;
@property (assign, nonatomic, readwrite) UtilityVector2 toolLocation;
@property (assign, nonatomic, readwrite) GLfloat toolTextureRadius;
@property (strong, nonatomic, readwrite) UtilityTextureInfo *lightAndWeightsTextureInfo;
@property (strong, nonatomic, readwrite) UtilityTextureInfo *detailTextureInfo0;
@property (strong, nonatomic, readwrite) UtilityTextureInfo *detailTextureInfo1;
@property (strong, nonatomic, readwrite) UtilityTextureInfo *detailTextureInfo2;
@property (strong, nonatomic, readwrite) UtilityTextureInfo *detailTextureInfo3;
@property (strong, nonatomic, readwrite) UtilityTextureInfo *toolTextureInfo;

// Designated initializer
- (id)initWithTerrain:(TETerrain *)aTerrain;
   
- (void)prepareToDraw;

- (void)updateTool;

@end
