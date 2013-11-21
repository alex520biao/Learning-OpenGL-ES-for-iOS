//
//  AGLKTextureRotationBaseEffect.h
// 
//

#import <GLKit/GLKit.h>

/////////////////////////////////////////////////////////////////
// This class extends GLKBaseEffect to enable use of separate
// texture matrices for each texture
// 
// Use -prepareToDrawWithTextures to when using multi-texture
// with textureMatrix0 and textureMatrix1.
//
// Use -prepareToDraw to get the inherited behavior from 
// GLKBaseEffect.
//
@interface AGLKTextureTransformBaseEffect : GLKBaseEffect

@property (assign) GLKVector4 light0Position;
@property (assign) GLKVector3 light0SpotDirection;
@property (assign) GLKVector4 light1Position;
@property (assign) GLKVector3 light1SpotDirection;
@property (assign) GLKVector4 light2Position;
@property (nonatomic, assign) GLKMatrix4 textureMatrix2d0;
@property (nonatomic, assign) GLKMatrix4 textureMatrix2d1;

- (void)prepareToDrawMultitextures;

@end


/////////////////////////////////////////////////////////////////
// Add convenience methods to GLKEffectPropertyTexture
//
// Use like
// [baseEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_S 
//    value:GL_REPEAT];
//
@interface GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID 
   value:(GLint)value;
   
@end
