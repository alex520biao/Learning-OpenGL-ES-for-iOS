//
//  TECart.h
//  OpenGLES_Ch12_1
//

#import <GLKit/GLKit.h>

@class TETerrain;
@class TECart;
@class TEParticleEmitter;
@class UtilityModel;
@class UtilityBillboardParticleManager;


@protocol TECartDelegateProtocol <NSObject>

/////////////////////////////////////////////////////////////////
// Returning NO prevents changes.
@optional
- (BOOL)cart:(TECart *)aCart
   willChangePosition:(GLKVector3 *)positionPtr;

@end


/////////////////////////////////////////////////////////////////
// Protocol for objects that control carts.
@protocol TECartControllerProtocol

- (NSTimeInterval)timeSinceLastUpdate;
- (TETerrain *)terrain;
- (UtilityBillboardParticleManager *)particleManager;
- (TECart *)playerCart;

@end


@interface TECart : NSObject

@property (assign, nonatomic, readwrite) 
   id <TECartDelegateProtocol> delegate;
@property (assign, nonatomic, readonly) 
   GLKVector3 position; 
@property (assign, nonatomic, readonly) 
   GLKVector3 velocity; 
@property (strong, nonatomic, readonly) 
   UtilityModel *model; 
@property (assign, nonatomic, readonly) 
   GLKVector3 upUnitVector;
@property (assign, nonatomic, readonly) 
   GLKVector3 rightUnitVector;
@property (assign, nonatomic, readonly) 
   GLKVector3 forwardUnitVector;
@property (assign, nonatomic, readonly) 
   GLfloat radius;
@property (assign, nonatomic, readonly) 
   GLfloat boostMagnitude;

@property (strong, nonatomic, readwrite)
   TEParticleEmitter *particleEmitter;
      

- (id)initWithModel:(UtilityModel *)aModel
   position:(GLKVector3)aPosition
   velocity:(GLKVector3)aVelocity;

- (void)updateWithController:
   (id <TECartControllerProtocol>)controller;

- (void)emitParticlesWithController:
   (id <TECartControllerProtocol>)controller;

- (GLKMatrix4)orientationMatrix;

- (void)turnDeltaRadians:(GLfloat)deltaRadians;
- (void)startBoosting;
- (void)stopBoosting;
- (void)stop;

- (void)bounceOffCarts:(NSArray *)carts
   elapsedTime:(NSTimeInterval)elapsedTimeSeconds;
- (GLfloat)radius;

@end
