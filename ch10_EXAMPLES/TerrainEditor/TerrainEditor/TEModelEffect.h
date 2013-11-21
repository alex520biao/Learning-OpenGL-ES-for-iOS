//
//  TEModelEffect.h
//  TerrainEditor
//

#import "TEEffect.h"
#import "UtilityTextureLoader.h"
#import "UtilityMatrix.h"


/////////////////////////////////////////////////////////////////
//  
typedef enum
{
   TEModelPositionAttrib,
   TEModelNormalAttrib,
   TEModelTexCoords0Attrib,
   TEModelNumberOfAttributes
} TEModelAttribute;


@interface TEModelEffect : TEEffect

@property (assign, nonatomic, readwrite) UtilityMatrix4 projectionMatrix;
@property (assign, nonatomic, readwrite) UtilityMatrix4 modelviewMatrix;
@property (assign, nonatomic, readwrite) UtilityVector4 globalAmbientLightColor;
@property (assign, nonatomic, readwrite) UtilityVector3 diffuseLightDirection;
@property (strong, nonatomic, readwrite) UtilityTextureInfo *texture2D;

@end
