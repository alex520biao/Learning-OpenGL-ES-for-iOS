//
//  AGLKPointParticleEffect.h
//  OpenGLES_Ch8_3
//

#import <GLKit/GLKit.h>

/////////////////////////////////////////////////////////////////
// Default gravity acceleration vector matches Earth's 
// {0, (-9.80665 m/s/s), 0} assuming +Y up coordinate system
extern const GLKVector3 AGLKDefaultGravity;

@interface AGLKPointParticleEffect : NSObject  <GLKNamedEffect>

@property (nonatomic, assign) GLKVector3 gravity;                
@property (nonatomic, assign) GLfloat elapsedSeconds;
@property (strong, nonatomic, readonly) GLKEffectPropertyTexture 
   *texture2d0;
@property (strong, nonatomic, readonly) GLKEffectPropertyTransform         
   *transform;

- (void)addParticleAtPosition:(GLKVector3)aPosition
   velocity:(GLKVector3)aVelocity
   force:(GLKVector3)aForce
   size:(float)aSize
   lifeSpanSeconds:(NSTimeInterval)aSpan
   fadeDurationSeconds:(NSTimeInterval)aDuration;

- (void)prepareToDraw;
- (void)draw;

@end
