//
//  SceneCar.m
//  
//

#import "SceneCar.h"
#import "UtilityModel+viewAdditions.h"


@interface SceneCar ()

@property (strong, nonatomic, readwrite) UtilityModel
   *model;
@property (assign, nonatomic, readwrite) GLKVector3 
   position;
@property (assign, nonatomic, readwrite) GLKVector3 
   nextPosition;
@property (assign, nonatomic, readwrite) GLKVector3 
   velocity;
@property (assign, nonatomic, readwrite) GLfloat 
   yawRadians;
@property (assign, nonatomic, readwrite) GLfloat 
   targetYawRadians;
@property (assign, nonatomic, readwrite) GLKVector4 
   color;
@property (assign, nonatomic, readwrite) GLfloat 
   radius;

@end


@implementation SceneCar

@synthesize model;
@synthesize position;
@synthesize velocity;
@synthesize yawRadians;
@synthesize targetYawRadians;
@synthesize color;
@synthesize nextPosition;
@synthesize radius;
   

/////////////////////////////////////////////////////////////////
// Returns nil
- (id)init
{
   NSAssert(0, @"Invalid initializer");
   
   self = nil;
   
   return self;
}


/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)initWithModel:(UtilityModel *)aModel
   position:(GLKVector3)aPosition
   velocity:(GLKVector3)aVelocity
   color:(GLKVector4)aColor;
{
   if(nil != (self = [super init]))
   {
      self.position = aPosition;
      self.color = aColor;
      self.velocity = aVelocity;
      self.model = aModel;
      
      AGLKAxisAllignedBoundingBox axisAlignedBoundingBox =
         self.model.axisAlignedBoundingBox;
      
      // Half the widest diameter is radius   
      self.radius = 0.5f * MAX(axisAlignedBoundingBox.max.x - 
         axisAlignedBoundingBox.min.x,
         axisAlignedBoundingBox.max.z - 
         axisAlignedBoundingBox.min.z);
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// This method detects any collisions between the receiver and
// walls in the simulation. Collisions case the receiver
// to "bounce off" the wall that was hit.
- (void)bounceOffWallsWithBoundingBox:
   (AGLKAxisAllignedBoundingBox)rinkBoundingBox
{
   if((rinkBoundingBox.min.x + self.radius) > 
      self.nextPosition.x)
   {
      self.nextPosition = GLKVector3Make(
         (rinkBoundingBox.min.x + self.radius),
         self.nextPosition.y, self.nextPosition.z);
      self.velocity = GLKVector3Make(-self.velocity.x,
         self.velocity.y, self.velocity.z);
   }
   else if((rinkBoundingBox.max.x - self.radius) < 
      self.nextPosition.x)
   {
      self.nextPosition = GLKVector3Make(
         (rinkBoundingBox.max.x - self.radius),
         self.nextPosition.y, self.nextPosition.z);
      self.velocity = GLKVector3Make(-self.velocity.x,
         self.velocity.y, self.velocity.z);
   } 
   
   if((rinkBoundingBox.min.z + self.radius) > 
      self.nextPosition.z)
   {
      self.nextPosition = GLKVector3Make(self.nextPosition.x,
         self.nextPosition.y, 
         (rinkBoundingBox.min.z + self.radius));
      self.velocity = GLKVector3Make(self.velocity.x,
         self.velocity.y, -self.velocity.z);
   }
   else if((rinkBoundingBox.max.z - self.radius) < 
      self.nextPosition.z)
   {
      self.nextPosition = GLKVector3Make(self.nextPosition.x,
         self.nextPosition.y, 
         (rinkBoundingBox.max.z - self.radius));
      self.velocity = GLKVector3Make(self.velocity.x,
         self.velocity.y, -self.velocity.z);
   }
}


/////////////////////////////////////////////////////////////////
// This method detects any collisions between the receiver and
// any other cars in the simulation. Collisions case the receiver
// to "bounce off" the car that was hit.
- (void)bounceOffCars:(NSArray *)cars
   elapsedTime:(NSTimeInterval)elapsedTimeSeconds
{
   for(SceneCar *currentCar in cars)
   {
      if(currentCar != self)
      {
         float    distance = GLKVector3Distance(
            self.nextPosition, currentCar.nextPosition);
            
         if((2.0f * self.radius) > distance)
         {  // cars have collided
            GLKVector3 ownVelocity = self.velocity;
            GLKVector3 otherVelocity = currentCar.velocity;
            GLKVector3 directionToOtherCar = GLKVector3Subtract(
               currentCar.position, 
               self.position);
            
            directionToOtherCar = GLKVector3Normalize(
               directionToOtherCar);
            GLKVector3 negDirectionToOtherCar = 
               GLKVector3Negate(directionToOtherCar);
                  
            GLKVector3 tanOwnVelocity = GLKVector3MultiplyScalar(
               negDirectionToOtherCar, GLKVector3DotProduct(
                  ownVelocity, negDirectionToOtherCar));
            GLKVector3 tanOtherVelocity = GLKVector3MultiplyScalar(
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
               
               // Update position based on velocity and time since last 
               // update
               self.nextPosition = GLKVector3Add(self.position, 
                  travelDistance);
            }
            
            {  // Update other car's velocity
               currentCar.velocity = GLKVector3Subtract(
                  otherVelocity,
                  tanOtherVelocity);
                  
               // Scale velocity based on elapsed time
               GLKVector3 travelDistance = 
                  GLKVector3MultiplyScalar(currentCar.velocity, 
                     elapsedTimeSeconds);
               
               // Update position based on velocity and time since last 
               // update
               currentCar.nextPosition = GLKVector3Add(
                  currentCar.position, 
                  travelDistance);
            }
         }
      }
   }
}


/////////////////////////////////////////////////////////////////
// This method updates the receiver's current yaw angle to be
// closer to the receiver's target yaw angle.
- (void)spinTowardDirectionOfMotion:(NSTimeInterval)elapsed
{
   self.yawRadians = SceneScalarSlowLowPassFilter(
      elapsed,
      self.targetYawRadians, 
      self.yawRadians);
}


/////////////////////////////////////////////////////////////////
// This method updates the position, yaw angle, and velocity of
// the receiver to simulate effects of collision with walls or
// other cars. 
- (void)updateWithController:
   (id <SceneCarControllerProtocol>)controller;
{  // Calculate elapsed time bounded between 1/100th sec. and
   // half a second
   NSTimeInterval   elapsedTimeSeconds = 
      MIN(MAX([controller timeSinceLastUpdate], 0.01f), 0.5f);
      
   // Scale velocity based on elapsed time
   GLKVector3 travelDistance = 
      GLKVector3MultiplyScalar(self.velocity, 
         elapsedTimeSeconds);
   
   // Update position based on velocity and time since last 
   // update
   self.nextPosition = GLKVector3Add(self.position, 
      travelDistance);   

   AGLKAxisAllignedBoundingBox rinkBoundingBox =
      [controller rinkBoundingBox];
   
   [self bounceOffCars:[controller cars] 
      elapsedTime:elapsedTimeSeconds];
   [self bounceOffWallsWithBoundingBox:rinkBoundingBox];

   // Accelerate if going slow
   if(0.1 > GLKVector3Length(self.velocity))
   {  // Got so slow that direction is unreliable so
      // launch in a new direction
      self.velocity = GLKVector3Make(
         (random() / (0.5f * RAND_MAX)) - 1.0f, // range -1 to 1
         0.0f,
         (random() / (0.5f * RAND_MAX)) - 1.0f);// range -1 to 1
   }
   else if(4 > GLKVector3Length(self.velocity))
   {  // Speed up in current direction
      self.velocity = GLKVector3MultiplyScalar(
         self.velocity,
         1.01f);
   }

   // The dot product is the cos() of the angle between two
   // vectors: in this case, the default orientation of the
   // car model and the car's velocity vector.
   float dotProduct = GLKVector3DotProduct(
      GLKVector3Normalize(self.velocity),
      GLKVector3Make(0.0, 0, -1.0));
   
   // Set the target yaw angle to match the car's direction of
   // motion
   if(0.0 > self.velocity.x)
   {  // Quadrants II and III use +acos()
      self.targetYawRadians = acosf(dotProduct);
   }
   else 
   {  // Quadrants IV and I use -acos()
      self.targetYawRadians = -acosf(dotProduct);
   }
   
   [self spinTowardDirectionOfMotion:elapsedTimeSeconds];
   
   self.position = self.nextPosition;
}


/////////////////////////////////////////////////////////////////
// Draw the receiver: This method sets anEffect's current 
// material color to the receivers color, translates to the 
// receiver's position, rotates to match the receiver's yaw 
// angle, draws the receiver's model. This method restores the 
// values of anEffect's properties to values in place when the 
// method was called.
- (void)drawWithBaseEffect:(GLKBaseEffect *)anEffect;
{
   // Save effect attributes that will be changed
   GLKMatrix4  savedModelviewMatrix = 
      anEffect.transform.modelviewMatrix;
   GLKVector4  savedDiffuseColor = 
      anEffect.material.diffuseColor;
   GLKVector4  savedAmbientColor = 
      anEffect.material.ambientColor;
   
   // Translate to the model's position
   anEffect.transform.modelviewMatrix = 
      GLKMatrix4Translate(savedModelviewMatrix,
          position.x, position.y, position.z);
          
   // Rotate to match model's yaw angle (rotation about Y)
   anEffect.transform.modelviewMatrix = 
      GLKMatrix4Rotate(anEffect.transform.modelviewMatrix,
          self.yawRadians,
          0.0, 1.0, 0.0);
   
   // Set the model's material color
   anEffect.material.diffuseColor = self.color; 
   anEffect.material.ambientColor = self.color;
       
   [anEffect prepareToDraw];
   
   // Draw the model
   [model draw];
   
   // Restore saved attributes   
   anEffect.transform.modelviewMatrix = savedModelviewMatrix;
   anEffect.material.diffuseColor = savedDiffuseColor;
   anEffect.material.ambientColor = savedAmbientColor;
}

@end


/////////////////////////////////////////////////////////////////
// This function returns a value between target and current. Call
// this function repeatedly to asymptotically return values closer
// to target: "ease in" to the target value.
GLfloat SceneScalarFastLowPassFilter(
   NSTimeInterval elapsed,    // seconds elapsed since last call
   GLfloat target,            // target value to approach
   GLfloat current)           // current value
{  // Constant 50.0 is an arbitrarily "large" factor
   return current + (50.0 * elapsed * (target - current));
}


/////////////////////////////////////////////////////////////////
// This function returns a value between target and current. Call
// this function repeatedly to asymptotically return values closer
// to target: "ease in" to the target value.
GLfloat SceneScalarSlowLowPassFilter(
   NSTimeInterval elapsed,    // seconds elapsed since last call
   GLfloat target,            // target value to approach
   GLfloat current)           // current value
{  // Constant 4.0 is an arbitrarily "small" factor
   return current + (4.0 * elapsed * (target - current));
}


/////////////////////////////////////////////////////////////////
// This function returns a vector between target and current. 
// Call repeatedly to asymptotically return vectors closer
// to target: "ease in" to the target value.
GLKVector3 SceneVector3FastLowPassFilter(
   NSTimeInterval elapsed,    // seconds elapsed since last call
   GLKVector3 target,         // target value to approach
   GLKVector3 current)        // current value
{  
   return GLKVector3Make(
      SceneScalarFastLowPassFilter(elapsed, target.x, current.x),
      SceneScalarFastLowPassFilter(elapsed, target.y, current.y),
      SceneScalarFastLowPassFilter(elapsed, target.z, current.z));
}


/////////////////////////////////////////////////////////////////
// This function returns a vector between target and current. 
// Call repeatedly to asymptotically return vectors closer
// to target: "ease in" to the target value.
GLKVector3 SceneVector3SlowLowPassFilter(
   NSTimeInterval elapsed,    // seconds elapsed since last call
   GLKVector3 target,         // target value to approach
   GLKVector3 current)        // current value
{  
   return GLKVector3Make(
      SceneScalarSlowLowPassFilter(elapsed, target.x, current.x),
      SceneScalarSlowLowPassFilter(elapsed, target.y, current.y),
      SceneScalarSlowLowPassFilter(elapsed, target.z, current.z));
}
