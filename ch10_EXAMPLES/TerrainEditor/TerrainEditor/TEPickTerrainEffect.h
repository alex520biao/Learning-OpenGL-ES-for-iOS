//
//  TEPickTerrainEffect.h
//  
//

#import "TEEffect.h"
#import "TEModelEffect.h"
#import "UtilityMatrix.h"
#import "UtilityTextureLoader.h"

@class TETerrain;
@class TEModelManager;


/////////////////////////////////////////////////////////////////
//  
typedef enum
{
   TEPickPositionAttrib = TEModelPositionAttrib,
   TEPickModelTexCoords0Attrib = TEModelTexCoords0Attrib,
   TEPickNumberOfAttributes = 3
} TEPickAttribute;


/////////////////////////////////////////////////////////////////
//  
typedef struct
{
   UtilityVector2 position;
   unsigned char modelIndex;
}
TEPickTerrainInfo;


@interface TEPickTerrainEffect : TEEffect

@property(assign, nonatomic, readwrite) UtilityMatrix4 projectionMatrix;
@property(assign, nonatomic, readwrite) UtilityMatrix4 modelviewMatrix;
@property(assign, nonatomic, readwrite) unsigned char modelIndex;
@property(strong, nonatomic, readwrite) UtilityTextureInfo *texture2D;

// Designated initializer
- (id)initWithTerrain:(TETerrain *)aTerrain;
   
- (TEPickTerrainInfo)positionAtMouseLocation:(UtilityVector2)mouseLocation
   aspectRatio:(GLfloat)anAspectRatio;

@end
