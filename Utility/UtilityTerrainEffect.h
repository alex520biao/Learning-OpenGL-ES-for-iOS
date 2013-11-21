//
//  UtilityTerrainEffect.h
//  
//

#import "UtilityEffect.h"
#import <GLKit/GLKit.h>

@class TETerrain;
@class UtilityTextureInfo;


@interface UtilityTerrainEffect : UtilityEffect

@property (assign, nonatomic, readwrite) 
   GLKVector4 globalAmbientLightColor;
@property (assign, nonatomic, readwrite) 
   GLKMatrix4 projectionMatrix;
@property (assign, nonatomic, readwrite) 
   GLKMatrix4 modelviewMatrix;
@property (assign, nonatomic, readwrite) 
   GLKMatrix3 textureMatrix0;
@property (assign, nonatomic, readwrite) 
   GLKMatrix3 textureMatrix1;
@property (assign, nonatomic, readwrite) 
   GLKMatrix3 textureMatrix2;
@property (assign, nonatomic, readwrite) 
   GLKMatrix3 textureMatrix3;
@property (strong, nonatomic, readwrite) 
   UtilityTextureInfo *lightAndWeightsTextureInfo;
@property (strong, nonatomic, readwrite) 
   UtilityTextureInfo *detailTextureInfo0;
@property (strong, nonatomic, readwrite) 
   UtilityTextureInfo *detailTextureInfo1;
@property (strong, nonatomic, readwrite) 
   UtilityTextureInfo *detailTextureInfo2;
@property (strong, nonatomic, readwrite) 
   UtilityTextureInfo *detailTextureInfo3;

// Designated initializer
- (id)initWithTerrain:(TETerrain *)aTerrain;
   
- (void)prepareToDraw;

@end
