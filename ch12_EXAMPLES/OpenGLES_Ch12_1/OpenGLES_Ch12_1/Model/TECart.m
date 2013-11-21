//
//  TECart.m
//  OpenGLES_Ch12_1
//

#import "TECart.h"
#import "TEParticleEmitter.h"
#import "TETerrain+modelAdditions.h"
#import "UtilityModel.h"
#import "UtilityBillboardParticleManager.h"
#import "AGLKFilters.h"
#import "AGLKAxisAllignedBoundingBox.h"


@interface TECart ()

@property (assign, nonatomic, readwrite) 
   GLKVector3 velocity; // speed and direction units per second
@property (assign, nonatomic, readwrite) 
   GLKVector3 position; 
@property (strong, nonatomic, readwrite) 
   UtilityModel *model; 
@property (assign, nonatomic, readwrite) 
   GLKVector3 upUnitVector;
@property (assign, nonatomic, readwrite) 
   GLKVector3 rightUnitVector;
@property (assign, nonatomic, readwrite) 
   GLKVector3 forwardUnitVector;

@property (assign, nonatomic, readwrite) 
   GLKVector3 targetUpUnitVector;
@property (assign, nonatomic, readwrite) 
   GLKVector3 targetRightUnitVector;
@property (assign, nonatomic, readwrite) 
   GLKVector3 targetForwardUnitVector;
@property (assign, nonatomic, readwrite) 
   GLfloat boostMagnitude;

@end


/////////////////////////////////////////////////////////////////
// Blocks for emitting particles from a cart
static TEParticleEmitterBlock TECartRocketParticleEmitterBlock;
static TEParticleEmitterBlock TECartSmokeParticleEmitterBlock;
static TEParticleEmitterBlock TECartDustParticleEmitterBlock;
 
 
@implementation TECart

@synthesize delegate = delegate_;
@synthesize velocity = velocity_;
@synthesize position = position_;
@synthesize model = model_;
@synthesize upUnitVector = upUnitVector_;
@synthesize rightUnitVector = rightUnitVector_;
@synthesize forwardUnitVector = forwardUnitVector_;
@synthesize targetUpUnitVector = targetUpUnitVector_;
@synthesize targetRightUnitVector = targetRightUnitVector_;
@synthesize targetForwardUnitVector = 
   targetForwardUnitVector_;
@synthesize radius = radius_;
@synthesize boostMagnitude = boostMagnitude_;
@synthesize particleEmitter = particleEmitter_;

/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)initWithModel:(UtilityModel *)aModel
   position:(GLKVector3)aPosition
   velocity:(GLKVector3)aVelocity
{
   if(nil != (self = [super init]))
   {
      position_ = aPosition;
      model_ = aModel;
      velocity_ = aVelocity;
      upUnitVector_ = GLKVector3Make(0.0f, 1.0f, 0.0f);
      targetUpUnitVector_ = upUnitVector_;
       
      if(0.1 < GLKVector3DotProduct(velocity_, velocity_))
      {  // Velocity squared needs to be reasonable
         forwardUnitVector_ = GLKVector3Normalize(velocity_);
      }
      else
      {  // aVelocity can't be used: Set some default
         forwardUnitVector_ = GLKVector3Make(0.0f, 0.0f, -1.0f);
      }
      targetForwardUnitVector_ = forwardUnitVector_;

      AGLKAxisAllignedBoundingBox axisAlignedBoundingBox =
         aModel.axisAlignedBoundingBox;
      
      // Half the narrowest diameter is radius   
      radius_ = 0.5f * MIN(axisAlignedBoundingBox.max.x - 
         axisAlignedBoundingBox.min.x,
         axisAlignedBoundingBox.max.z - 
         axisAlignedBoundingBox.min.z);
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// override of inherited initializer
- (id)init
{
   NSAssert(0, @"Invalid initializer");
   
   return nil;
}


/////////////////////////////////////////////////////////////////
// Emit particles based on whether carts is accelerating or not.
- (void)emitParticlesWithController:
   (id <TECartControllerProtocol>)controller
{
   if(1.0f < self.boostMagnitude)
   {  // Cart is accelerating (boosting)
      [self.particleEmitter updateWithParticleEmitterBlock:
            TECartRocketParticleEmitterBlock
         manager:controller.particleManager 
         elapsedTime:controller.timeSinceLastUpdate 
         owner:self];
   }
   else
   {  // Cart is decelerating (no boost)
      [self.particleEmitter updateWithParticleEmitterBlock:
            TECartSmokeParticleEmitterBlock 
         manager:controller.particleManager 
         elapsedTime:controller.timeSinceLastUpdate 
         owner:self];
   }
   
   // Emit dust from under cart
   [self.particleEmitter updateWithParticleEmitterBlock:
         TECartDustParticleEmitterBlock 
      manager:controller.particleManager 
      elapsedTime:controller.timeSinceLastUpdate 
      owner:self];
}   


/////////////////////////////////////////////////////////////////
// The maximum elasped seconds between updates for using 
// particles. (If the elapsed time exceeds this number, avoid 
// emitting more particles). 
static const GLfloat TEMaximumUpdatePeriodForParticles = 
   (1.0f / 20.0f);

/////////////////////////////////////////////////////////////////
// The acceleration from boosting in meters per second per 
// second.
static const GLfloat TEBoostMagnitude = (12.0f);

/////////////////////////////////////////////////////////////////
// The deceleration from dynamic friction in meters per second 
// per second. Dynamic friction only applies when cart is in
// motion. 
static const GLfloat TEFrictionMagnitude = (-2.0f);

/////////////////////////////////////////////////////////////////
// The deceleration factor for air resistance is proportional to
// speed squared and effectively limits vehicle's top speed. 
static const GLfloat TEAirResistanceMagnitude = (-0.03);


/////////////////////////////////////////////////////////////////
// Earth's gravitational acceleration constant in meters per 
// second per second.
static const GLKVector3 TEGravityAcceleration = 
   {0.0f, -9.80665f, 0.0f};
   

/////////////////////////////////////////////////////////////////
// Returns the total acceleration from all factors including 
// boost, gravity, air resistance, and dynamic friction.
- (GLKVector3)totalAcceleration
{
   // Accelerate from boost
   GLKVector3 totalAccelerationVector = GLKVector3MultiplyScalar(
      self.forwardUnitVector,
      self.boostMagnitude);
      
   // Add the effect of gravity
   totalAccelerationVector = GLKVector3Add(
      totalAccelerationVector,
      TEGravityAcceleration);

   GLfloat speedSquared = GLKVector3DotProduct(self.velocity, 
      self.velocity);

   // Reduce velocity to account for friction
   if(1.0f < speedSquared)
   {  // there is ground friction as long as we are moving
      totalAccelerationVector = GLKVector3Add(
         totalAccelerationVector,
         GLKVector3MultiplyScalar(
            self.forwardUnitVector, 
            TEFrictionMagnitude));
            
      // there is air friction proportional to speed squared
      totalAccelerationVector = GLKVector3Add(
         totalAccelerationVector,
         GLKVector3MultiplyScalar(
            self.forwardUnitVector, 
            TEAirResistanceMagnitude * speedSquared));
   }
   
   return totalAccelerationVector;
}


/////////////////////////////////////////////////////////////////
// Returns candidate new velocity and position based on Newtonian
// physics using current velocity and position, acceleration,
// orientation, and elapsed time.
- (void)getNewVelocity:(GLKVector3 *)newVelocityPtr
   andPosition:(GLKVector3 *)newPositionPtr
   forVelocity:(GLKVector3)currentVelocity
   position:(GLKVector3)currentPosition
   elapsedTime:(NSTimeInterval)elapsedTime
{
   NSParameterAssert(NULL != newVelocityPtr);
   NSParameterAssert(NULL != newPositionPtr);
   
   // Accelerate from boost
   GLKVector3 totalAccelerationVector = [self totalAcceleration];
   
   // Mass is assumed to be 1.0, so acceleration = force (a = f/m)
   // v = v0 + at : v is new velocity; v0 is current velocity;
   //               a is acceleration; t is elapsed time
   GLKVector3 newVelocity = GLKVector3Add(
      currentVelocity,
      GLKVector3MultiplyScalar(
         totalAccelerationVector, 
         elapsedTime));
   
   // Calculate new position based on newVelocity
   // s = s0 + 0.5 * (v0 + v) * t : s is new position; 
   //                              s0 is current position;
   //                              v0 is current velocity; 
   //                              v is new velocity;
   //                              t is elapsed time
   GLKVector3 newPosition = GLKVector3Add(currentPosition,
      GLKVector3MultiplyScalar(
         GLKVector3Add(currentVelocity, newVelocity), 
         0.5f * elapsedTime));
         
   *newVelocityPtr = newVelocity;
   *newPositionPtr = newPosition;
}


/////////////////////////////////////////////////////////////////
// Returns new position by calculating the height and orientation 
// needed to slide along the terrain surface at newPosition.x
// newPosition.z. If surfaceNormalPtr is not NULL, this method
// returns the terrain surface normal at the new position via
// surfaceNormalPtr.
- (GLKVector3)constrainPosition:(GLKVector3)newPosition
   toTerrain:(TETerrain *)terrain
   surfaceNormal:(GLKVector3 *)surfaceNormalPtr
{
   NSAssert([terrain isHeightValidAtXPosMeters:newPosition.x 
      zPosMeters:newPosition.z], @"Cart is off the map.");
     
   newPosition.y = 
      [terrain calculatedHeightAtXPosMeters:newPosition.x
         zPosMeters:newPosition.z
         surfaceNormal:surfaceNormalPtr];
      
   return newPosition;
}


/////////////////////////////////////////////////////////////////
// Set the receiver's position if giving delegate a chance to 
// meddle and/or veto the change.
- (void)attemptToSetPosition:(GLKVector3)newPosition
{
   
   if([self.delegate respondsToSelector:
      @selector(cart:willChangePosition:)])
   {
      if([self.delegate cart:self 
         willChangePosition:&newPosition])
      {
         self.position = newPosition;
      }
   }
   else
   {
      self.position = newPosition;
   }
}


/////////////////////////////////////////////////////////////////
// This method updates the receiver's target orientation based
// the specified velocity and surface normal.
- (void)updateTargetOrientationForVelocity:
      (GLKVector3)newVelocity
   surfaceNormal:(GLKVector3)surfaceNormal
{
   NSParameterAssert(0.0f < surfaceNormal.y);

   // Calculate target vehicle orientation to align with 
   // terrain surface
   self.targetUpUnitVector = surfaceNormal;

   // Assume velocityUnitVector is the same as current 
   // target forward vector      
   GLKVector3 velocityUnitVector = self.targetForwardUnitVector;
   
   const GLKVector3 newHorizontalVelocity = 
      GLKVector3Make(newVelocity.x, 0.0f, newVelocity.z);
      
   if(0.5f < GLKVector3DotProduct(newHorizontalVelocity, 
      newHorizontalVelocity))
   {  // Velocity is large enough to recalculate cart orientation
      // including new forward vector
      velocityUnitVector = GLKVector3Normalize(newVelocity);
      //NSLog(@"{%0.2f, %0.2f, %0.2f}", velocityUnitVector.x,
      //   velocityUnitVector.y, velocityUnitVector.z);
   }

   self.targetRightUnitVector = GLKVector3CrossProduct(
      velocityUnitVector, self.targetUpUnitVector);
   self.targetForwardUnitVector = GLKVector3CrossProduct(
      self.targetUpUnitVector, self.targetRightUnitVector);
}


/////////////////////////////////////////////////////////////////
// This method uses time based filters to make the receiver's
// current orientation approach the receiver's target orientation.
- (void)updateOrientationForElapsedTime:
   (NSTimeInterval)elapsedTime
{
   GLKVector3 vehicleUp = self.upUnitVector;
   if(0.0f >= vehicleUp.y)
   {  // Invalid up means vehicle orientation uninitialized
      // set equal to target orientation
      self.upUnitVector = self.targetUpUnitVector;
      self.rightUnitVector = self.targetRightUnitVector;
      self.forwardUnitVector = self.targetForwardUnitVector;
   } 
   else
   {  // make current orientation approach target orientation
      self.upUnitVector = AGLKVector3SlowLowPassFilter(
         MIN(1.0f, elapsedTime),
         self.targetUpUnitVector,
         self.upUnitVector);
      self.upUnitVector = 
         GLKVector3Normalize(self.upUnitVector);
      self.rightUnitVector = AGLKVector3SlowLowPassFilter(
         MIN(1.0f, elapsedTime),
         self.targetRightUnitVector,
         self.rightUnitVector);
      self.rightUnitVector = 
         GLKVector3Normalize(self.rightUnitVector);
      self.forwardUnitVector = AGLKVector3SlowLowPassFilter(
         MIN(1.0f, elapsedTime),
         self.targetForwardUnitVector,
         self.forwardUnitVector);
      self.forwardUnitVector = 
         GLKVector3Normalize(self.forwardUnitVector);
   }
   
   NSAssert((0.9f < GLKVector3DotProduct(
      self.forwardUnitVector, self.forwardUnitVector)) &&
      (1.1f > GLKVector3DotProduct(self.forwardUnitVector, 
         self.forwardUnitVector)),
      @"Invalid forwardUnitVector");
}


/////////////////////////////////////////////////////////////////
// This method makes basic decisions for non-player controlled
// carts.
- (void)executeAIForElapsedTime:(NSTimeInterval)elapsedTime
{
   NSInteger randomNumber = 
      random() % (NSInteger)(1.0f / MIN(1.0f, elapsedTime));
      
   if(0 == randomNumber)
   {  // Toggle boost
      if(1.0 > self.boostMagnitude)
      {
         [self startBoosting];
      }
      else
      {
         [self stopBoosting];
      }
   }
}


/////////////////////////////////////////////////////////////////
// This method updates the position and orientation of
// the receiver to simulate effects of rolling over terrain. 
- (void)updateWithController:
   (id <TECartControllerProtocol>)controller;
{
   const NSTimeInterval elapsedTime = MIN(1.0f,
      [controller timeSinceLastUpdate]);
   TETerrain *terrain = [controller terrain];

   if(elapsedTime <= 0.0f)
   {  // This is the first update, and self.position my not be 
      // valid yet. On this update, just make it valid.
      
      // Constrain the new position to remain on the surface of
      // the terrain
      GLKVector3 surfaceNormal;
      
      GLKVector3 newPosition = 
         [self constrainPosition:self.position
         toTerrain:terrain
         surfaceNormal:&surfaceNormal];

      // Set the new position giving the delegate a chance to 
      // meddle
      [self attemptToSetPosition:newPosition];      
   }
   else
   {   
      if(self != [controller playerCart])
      { // This cart is controlled by computer so do something 
        // interesting.
        [self executeAIForElapsedTime:elapsedTime];
      }
   
      const GLKVector3 currentPosition = self.position;      
      GLKVector3 newVelocity;
      GLKVector3 newPosition;
      
      // Get the candidate new velocity and position based on 
      // physics
      [self getNewVelocity:&newVelocity
         andPosition:&newPosition
         forVelocity:self.velocity
         position:self.position
         elapsedTime:elapsedTime];
      
      // Constrain the new position to remain on the surface of
      // the terrain
      GLKVector3 surfaceNormal;
      
      newPosition = [self constrainPosition:newPosition
         toTerrain:terrain
         surfaceNormal:&surfaceNormal];
      
      // Set the new position giving the delegate a chance to 
      // meddle
      [self attemptToSetPosition:newPosition];
      
       // Regardless of calculated velocity, actual velocity 
       // is the distance traveled divide by the time it took.
       // This recalculation is needed because 
       // -attemptToSetPosition: may have modified the new
       // position.
       newVelocity = GLKVector3MultiplyScalar(
          GLKVector3Subtract(self.position, currentPosition),
          1.0f/elapsedTime);
         
      // Update target orientation 
      [self updateTargetOrientationForVelocity:newVelocity
         surfaceNormal:surfaceNormal];
         
      self.velocity = newVelocity;
            
      // Update current orientation to approach target 
      // orientation
      [self updateOrientationForElapsedTime:elapsedTime];
      
      // Don't bother emitting particles unless display update
      // rate is fast enough (This is a small feature to drop
      // and potebtially improve frame rate).
      if(TEMaximumUpdatePeriodForParticles >= elapsedTime)
      {  // Emit particles from cart
         [self emitParticlesWithController:controller];
      }
   }
   
}


/////////////////////////////////////////////////////////////////
// Returns a matrix that encodes the receiver's current 
// orientation a.k.a pitch, yaw, and roll
- (GLKMatrix4)orientationMatrix;
{
   GLKVector3 xNormal = self.rightUnitVector;
   GLKVector3 yNormal = self.upUnitVector;
   GLKVector3 zNormal = self.forwardUnitVector;
   
   // Create a matrix to match the cart's orientation
   GLKMatrix4 cartMatrix = {
      // X Axis     Y Axis     Z Axis 
      -xNormal.x, yNormal.x, zNormal.x,           0.0f,
      -xNormal.y, yNormal.y, zNormal.y,           0.0f,
      -xNormal.z, yNormal.z, zNormal.z,           0.0f,

      // Axis Origin
      0, 0, 0,                                    1.0f
   };
   
   return cartMatrix;
}


/////////////////////////////////////////////////////////////////
// Modify the receiver's velocity direction to yaw deltaRadians.
// (turn about the up direction)
- (void)turnDeltaRadians:(GLfloat)deltaRadians;
{
   GLKMatrix4 rotationMatrix = GLKMatrix4MakeRotation(
      deltaRadians, 
      0.0f, 1.0f, 0.0f);
      
   self.velocity = GLKMatrix4MultiplyVector3(
      rotationMatrix, self.velocity);
}


/////////////////////////////////////////////////////////////////
// Modify the receiver's current acceleration to include the 
// boost.
- (void)startBoosting;
{
   self.boostMagnitude = TEBoostMagnitude;
}


/////////////////////////////////////////////////////////////////
// Modify the receiver's current acceleration to remove any 
// boost.
- (void)stopBoosting;
{
   self.boostMagnitude = 0.0f;
}


/////////////////////////////////////////////////////////////////
// Set a minimal velocity just so cart has a deterministic 
// orientation. When perfectly still, cart doesn't know which
// direction to face.
- (void)stop;
{
   self.velocity = GLKVector3Multiply(
      self.forwardUnitVector,
      GLKVector3Make(-0.1f, 0.0f, -0.1f));
}

/////////////////////////////////////////////////////////////////
// This method detects any collisions between the receiver and
// other carts in the simulation. Collisions make the receiver
// and the hit care "bounce off" each other.
- (void)bounceOffCarts:(NSArray *)carts
   elapsedTime:(NSTimeInterval)elapsedTimeSeconds
{
   for(TECart *currentCart in carts)
   {
      if(currentCart != self)
      {
         const GLfloat    distance = GLKVector3Distance(
            self.position, currentCart.position);
            
         if((2.0f * self.radius) > distance)
         {  // cars have collided
            GLKVector3 ownVelocity = self.velocity;
            GLKVector3 otherVelocity = currentCart.velocity;
            GLKVector3 directionToOtherCar = GLKVector3Subtract(
               currentCart.position, 
               self.position);
            
            directionToOtherCar = GLKVector3Normalize(
               directionToOtherCar);
            GLKVector3 negDirectionToOtherCar = 
               GLKVector3Negate(directionToOtherCar);
                  
            GLKVector3 tanOwnVelocity = 
               GLKVector3MultiplyScalar(
               negDirectionToOtherCar, GLKVector3DotProduct(
                  ownVelocity, negDirectionToOtherCar));
            GLKVector3 tanOtherVelocity = 
               GLKVector3MultiplyScalar(
               directionToOtherCar, GLKVector3DotProduct(
                  otherVelocity, directionToOtherCar));
                           
            {  // Update own velocity
               self.velocity = GLKVector3Subtract(
                  ownVelocity,
                  tanOwnVelocity);

               // Scale velocity based on elapsed time
               GLKVector3 travelDistance = 
                  GLKVector3MultiplyScalar(self.velocity, 
                     elapsedTimeSeconds);
               
               // Update position based on velocity and time 
               // since last update
               self.position = GLKVector3Add(self.position, 
                  travelDistance);
            }
            
            {  // Update other car's velocity
               currentCart.velocity = GLKVector3Subtract(
                  otherVelocity,
                  tanOtherVelocity);
                  
               // Scale velocity based on elapsed time
               GLKVector3 travelDistance = 
                  GLKVector3MultiplyScalar(currentCart.velocity, 
                     elapsedTimeSeconds);
               
               // Update position based on velocity and time 
               // since last update
               currentCart.position = GLKVector3Add(
                  currentCart.position, 
                  travelDistance);
            }
         }
      }
   }
}

@end


/////////////////////////////////////////////////////////////////
// Emit lazy smoke particles that drift up
static TEParticleEmitterBlock 
TECartDustParticleEmitterBlock = ^(
   GLKVector3 position,
   UtilityBillboardParticleManager *manager,
   NSTimeInterval elapsedTime,
   id owner)
{
   static const int maxNumberOfEmittedParticles = 10;
   TECart *cart = (TECart *)owner;
   
   // Emit particles from under cart
   for(NSInteger i = 0; i < maxNumberOfEmittedParticles; i++)
   {
      GLKVector3 velocity = GLKVector3Make(
         2.0f - (4.0f * random() / (GLfloat)RAND_MAX), 
         0.0f, 
         2.0f - (4.0f * random() / (GLfloat)RAND_MAX));
      velocity = GLKVector3Add(velocity,
         GLKVector3MultiplyScalar(cart.velocity, 0.8f));
         
      [manager 
         addParticleAtPosition:cart.position
         velocity:velocity 
         force:GLKVector3Make(0.0f, 0.0f, 0.0f) 
         initialSize:GLKVector2Make(0.0f, 0.0f) 
         finalSize:GLKVector2Make(cart.radius, cart.radius) 
         lifeSpanSeconds:0.8f 
         fadeDurationSeconds:0.8f 
         minTextureCoords:GLKVector2Make(0.26f, 0.01f)
         maxTextureCoords:GLKVector2Make(0.49f, 0.24f)];
   }
};


/////////////////////////////////////////////////////////////////
// Emit lazy smoke particles that drift up
static TEParticleEmitterBlock 
TECartSmokeParticleEmitterBlock = ^(
   GLKVector3 position,
   UtilityBillboardParticleManager *manager,
   NSTimeInterval elapsedTime,
   id owner)
{
   TECart *cart = (TECart *)owner;
   
   // Emit particle from rocket
   GLKVector3 particlePosition = 
      GLKVector3Add(cart.position, 
      GLKVector3MultiplyScalar(cart.forwardUnitVector, 
         position.z));
   particlePosition = 
      GLKVector3Add(particlePosition, 
      GLKVector3MultiplyScalar(cart.rightUnitVector, 
         position.x));
   particlePosition = 
      GLKVector3Add(particlePosition, 
      GLKVector3MultiplyScalar(cart.upUnitVector, 
         position.y));

  GLKVector3 cumulativeForce = GLKVector3Add(
      GLKVector3Make(0.0f, -10.0f, 0.0f),
      GLKVector3MultiplyScalar(cart.forwardUnitVector, 
         -0.5f));
            
   [manager 
      addParticleAtPosition:particlePosition
      velocity:GLKVector3MultiplyScalar(cart.velocity, 0.8f) 
      force:cumulativeForce 
      initialSize:GLKVector2Make(0.01f, 0.01f) 
      finalSize:GLKVector2Make(0.8f, 0.8f) 
      lifeSpanSeconds:0.4f 
      fadeDurationSeconds:0.6f 
      minTextureCoords:GLKVector2Make(0.26f, 0.01f)
      maxTextureCoords:GLKVector2Make(0.49f, 0.24f)];
};


/////////////////////////////////////////////////////////////////
// Emit multiple rocket blast particles
static TEParticleEmitterBlock 
TECartRocketParticleEmitterBlock = ^(
   GLKVector3 position,
   UtilityBillboardParticleManager *manager,
   NSTimeInterval elapsedTime,
   id owner)
{
   TECart *cart = (TECart *)owner;
   
   int i = 0;   // counter of particles emitted
   static const int maxNumberOfEmittedParticles = 10;
   
   GLKVector3 particlePosition = 
      GLKVector3Add(cart.position, 
      GLKVector3MultiplyScalar(cart.forwardUnitVector, 
         position.z));
   particlePosition = 
      GLKVector3Add(particlePosition, 
      GLKVector3MultiplyScalar(cart.rightUnitVector, 
         position.x));
   particlePosition = 
      GLKVector3Add(particlePosition, 
      GLKVector3MultiplyScalar(cart.upUnitVector, 
         position.y));

   GLKVector3 particlePositionDelta = 
      GLKVector3MultiplyScalar(cart.forwardUnitVector, 
         -0.06f);
        
   do 
   {  // Emit particles with increasing displacements from
      // emitter position
      particlePosition = 
         GLKVector3Add(particlePosition, 
         particlePositionDelta);
            
      GLKVector3 cumulativeForce = GLKVector3Add(
         GLKVector3Make(0.0f, -5.5f, 0.0f),
         GLKVector3MultiplyScalar(cart.forwardUnitVector, 
            -15.0f));
            
      [manager 
         addParticleAtPosition:particlePosition
         velocity:GLKVector3MultiplyScalar(cart.velocity, 0.8f) 
         force:cumulativeForce 
         initialSize:GLKVector2Make(0.3f - (i / 80.0f), 0.3f - 
            (i / 80.0f)) 
         finalSize:GLKVector2Make(0.0f, 0.0f) 
         lifeSpanSeconds:0.25f 
         fadeDurationSeconds:0.1f 
         minTextureCoords:GLKVector2Make(0.01f, 0.01f)
         maxTextureCoords:GLKVector2Make(0.24f, 0.24f)];
         
      i++;
           
   } while (i < maxNumberOfEmittedParticles);
};
