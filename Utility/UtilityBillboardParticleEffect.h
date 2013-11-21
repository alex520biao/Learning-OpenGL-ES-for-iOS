//
//  BillboardParticleEffect.h
//  
//

#import "UtilityEffect.h"
#import <GLKit/GLKit.h>  


@interface UtilityBillboardParticleEffect : UtilityEffect

@property (assign, nonatomic, readwrite) GLKMatrix4 
   projectionMatrix;
@property (assign, nonatomic, readwrite) GLKMatrix4 
   modelviewMatrix;
@property (strong, nonatomic, readwrite) GLKTextureInfo *
   texture2D;

@end
