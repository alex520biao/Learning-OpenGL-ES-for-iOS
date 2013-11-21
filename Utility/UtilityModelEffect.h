//
//  UtilityModelEffect.h
//  
//

#import "UtilityEffect.h"
#import <GLKit/GLKit.h>  


@interface UtilityModelEffect : UtilityEffect

@property (assign, nonatomic, readwrite) GLKMatrix4 
   projectionMatrix;
@property (assign, nonatomic, readwrite) GLKMatrix4 
   modelviewMatrix;
@property (assign, nonatomic, readwrite) GLKVector4    
   globalAmbientLightColor;
@property (assign, nonatomic, readwrite) GLKVector3 
   diffuseLightDirection;
@property (assign, nonatomic, readwrite) GLKVector4    
   diffuseLightColor;
@property (strong, nonatomic, readwrite) GLKTextureInfo *
   texture2D;

- (void)prepareLightColors;
- (void)prepareModelview;
- (void)prepareModelviewWithoutNormal;

@end
