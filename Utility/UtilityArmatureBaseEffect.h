//
//  UtilityArmatureBaseEffect.h
// 
//

#import <GLKit/GLKit.h>

/////////////////////////////////////////////////////////////////
// 
typedef enum {
    UtilityArmatureVertexAttribPosition = 
       GLKVertexAttribPosition,
    UtilityArmatureVertexAttribNormal = 
       GLKVertexAttribNormal,
    UtilityArmatureVertexAttribTexCoord0 = 
       GLKVertexAttribTexCoord0,
    UtilityArmatureVertexAttribTexCoord1 = 
       GLKVertexAttribTexCoord1,
    UtilityArmatureVertexAttribJointMatrixIndices,
    UtilityArmatureVertexAttribJointNormalizedWeights,
} UtilityArmatureVertexAttrib;


/////////////////////////////////////////////////////////////////
// This class extends GLKBaseEffect to enable use of separate
// texture matrices for each texture and implement armature based
// "skeletal" animation.
// 
// Call -prepareToDrawArmature to apply multi-texture
// with textureMatrix0 and textureMatrix1 and when using the 
// joints specified by the jointsArray property.
//
// Use -prepareToDraw to get the inherited behavior from 
// GLKBaseEffect.
//
@interface UtilityArmatureBaseEffect : GLKBaseEffect

@property (assign) GLKVector4 light0Position;
@property (assign) GLKVector3 light0SpotDirection;
@property (assign) GLKVector4 light1Position;
@property (assign) GLKVector3 light1SpotDirection;
@property (assign) GLKVector4 light2Position;
@property (nonatomic, assign) GLKMatrix4 textureMatrix2d0;
@property (nonatomic, assign) GLKMatrix4 textureMatrix2d1;
@property (strong, nonatomic) NSArray *jointsArray;

- (void)prepareToDrawArmature;
    
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
