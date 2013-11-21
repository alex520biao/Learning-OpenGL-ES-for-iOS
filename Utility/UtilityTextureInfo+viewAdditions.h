//
//  UtilityTextureInfo+viewAdditions.h
//  
//

#import "UtilityTextureInfo.h"
#import <GLKit/GLKit.h>

@interface GLKTextureInfo (utilityAdditions)

+ (GLKTextureInfo *)textureInfoFromUtilityPlistRepresentation:
   (NSDictionary *)aDictionary;
   
@end


@interface UtilityTextureInfo (viewAdditions)

@property (nonatomic, readonly, assign) GLuint name;
@property (nonatomic, readonly, assign) GLenum target;

@end
