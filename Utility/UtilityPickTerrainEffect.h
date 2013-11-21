//
//  TEPickTerrainEffect.h
//  
//

#import "UtilityEffect.h"
#import <GLKit/GLKit.h>

@class TETerrain;
@class TEModelManager;


typedef struct
{
   GLKVector2 position;
   unsigned char modelIndex;
}
TEPickTerrainInfo;


@interface UtilityPickTerrainEffect : UtilityEffect

@property(assign, nonatomic, readwrite) 
   GLKMatrix4 projectionMatrix;
@property(assign, nonatomic, readwrite) 
   GLKMatrix4 modelviewMatrix;
@property(assign, nonatomic, readwrite) 
   unsigned char modelIndex;

// Designated initializer
- (id)initWithTerrain:(TETerrain *)aTerrain;

- (TEPickTerrainInfo)terrainInfoForProjectionPosition:
   (GLKVector2)aPosition;

@end
