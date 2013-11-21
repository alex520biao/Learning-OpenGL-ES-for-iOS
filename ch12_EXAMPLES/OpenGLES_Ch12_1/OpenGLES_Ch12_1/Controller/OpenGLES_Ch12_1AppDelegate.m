//
//  OpenGLES_Ch12_1AppDelegate.m
//  OpenGLES_Ch12_1
//

#import "OpenGLES_Ch12_1AppDelegate.h"
#import "TETerrain+modelAdditions.h"
#import "TECart.h"
#import "TEParticleEmitter.h"
#import "UtilityModelManager.h"
#import "UtilityMesh.h"


@interface OpenGLES_Ch12_1AppDelegate ()

@property (strong, nonatomic, readwrite) TETerrain *terrain;

@property (readonly, strong, nonatomic) 
   NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) 
   NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) 
   NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end


/////////////////////////////////////////////////////////////////
// 
@implementation OpenGLES_Ch12_1AppDelegate

@synthesize terrain = terrain_;
@synthesize modelManager = modelManager_;
@synthesize playerModelManager = playerModelManager_;
@synthesize carts = carts_;

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

/////////////////////////////////////////////////////////////////
// 
- (BOOL)application:(UIApplication *)application 
   didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   NSFetchRequest *request = 
      [[NSFetchRequest alloc] init];
   NSEntityDescription *entity =
      [NSEntityDescription entityForName:@"Terrain"
      inManagedObjectContext:[self managedObjectContext]];
   [request setEntity:entity];
   
   NSArray *terrainArray = nil;
   NSError *error = nil;
   
   @try 
   {
      terrainArray = 
         [[self managedObjectContext] 
         executeFetchRequest:request error:&error];
   }
   @catch (NSException *exception) 
   {
       NSLog(@"%@", exception);
   }
   @finally 
   {
   }
   
   if (terrainArray != nil) 
   {
      NSUInteger count = [terrainArray count]; 
      
      if(1 == count)
      {  // Use the existing instance
         self.terrain = [terrainArray lastObject];
      }
      else
      {  // Too many existing instances or not enough
         // Deal with error.
      }
   }
   else 
   { 
      // Deal with error.
   }
   
   return YES;
}


/////////////////////////////////////////////////////////////////
// 
- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[application setStatusBarHidden:YES 
      withAnimation:UIStatusBarAnimationFade];
}


/////////////////////////////////////////////////////////////////
// 
- (void)applicationWillTerminate:(UIApplication *)application
{
   // Saves changes in the application's managed object context before the application terminates.
   [self saveContext];
}


/////////////////////////////////////////////////////////////////
// 
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = 
       self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && 
           ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", 
               error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/////////////////////////////////////////////////////////////////
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound 
// to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = 
       [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = 
           [[NSManagedObjectContext alloc] init];
        [__managedObjectContext 
           setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}


/////////////////////////////////////////////////////////////////
// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the 
// application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] 
       URLForResource:@"OpenGLES_Ch12_1" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] 
       initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}


/////////////////////////////////////////////////////////////////
// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and 
// the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[NSBundle mainBundle] 
       URLForResource:@"trail" withExtension:@"binary"];
    NSDictionary *options =
       [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                    forKey:NSReadOnlyPersistentStoreOption];     
    NSError *error = nil;
    __persistentStoreCoordinator = 
       [[NSPersistentStoreCoordinator alloc] 
          initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSBinaryStoreType configuration:nil 
       URL:storeURL options:options error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/////////////////////////////////////////////////////////////////
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] 
       URLsForDirectory:NSDocumentDirectory 
       inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Model Manager

//////////////////////////////////////////////////////////////////
//  
- (UtilityModelManager *)modelManager
{
   if(modelManager_ == nil &&
      nil != self.terrain.modelsData)
   {
      modelManager_ = [[UtilityModelManager alloc] init];
      [modelManager_ readFromData:self.terrain.modelsData 
         ofType:nil 
         error:NULL];
   }
      
   return modelManager_;
}


//////////////////////////////////////////////////////////////////
//  
- (UtilityModelManager *)playerModelManager
{
   if(nil == playerModelManager_)
   {
      NSString *modelPath = [[NSBundle mainBundle] pathForResource:
         @"cart007" ofType:@"modelplist"];
      playerModelManager_ = 
         [[UtilityModelManager alloc] initWithModelPath:modelPath];
      playerModelManager_.consolidatedMesh.shouldUseVAOExtension = 
         YES;
   }
      
   return playerModelManager_;
}


#pragma mark - Player

//////////////////////////////////////////////////////////////////
// Return the array of carts in the game. Creates the carts if 
// necessary.
- (NSArray *)carts
{
   if(nil == carts_)
   {
      UtilityModel *model = 
         [self.playerModelManager modelNamed:@"cart"];
      NSAssert(nil != model, 
         @"Failed to load cart model");
        
      UtilityModel *particleEmitterModel = 
         [self.playerModelManager modelNamed:@"particleEmitter"];
      NSAssert(nil != particleEmitterModel, 
         @"Failed to load particleEmitter model");
      
      // Create a particle emitter to be shared by all the carts
      TEParticleEmitter *particleEmitter = 
         [[TEParticleEmitter alloc] initWithModel:
            particleEmitterModel];
      
      // Initial velocity
      GLKVector3 velocity = GLKVector3MultiplyScalar(
         GLKVector3Make(0.0f, 0.0f, 1.0f), 4.0f);
      
      // Create and configure the carts
      TECart *cart0 = [[TECart alloc] 
         initWithModel:model
         position:GLKVector3Make(480.0f, 0.0f, 380.0f)
         velocity:velocity];
      cart0.delegate = self;
      cart0.particleEmitter = particleEmitter;
      
      TECart *cart1 = [[TECart alloc] 
         initWithModel:model
         position:GLKVector3Make(483.0f, 0.0f, 383.0f)
         velocity:velocity];
      cart1.delegate = self;
      cart1.particleEmitter = particleEmitter;
      
      TECart *cart2 = [[TECart alloc] 
         initWithModel:model
         position:GLKVector3Make(479.0f, 0.0f, 383.5f)
         velocity:velocity];
      cart2.delegate = self;
      cart2.particleEmitter = particleEmitter;
      
         
      carts_ = [NSArray arrayWithObjects:
         cart0, 
         cart1, 
         cart2, 
         nil];
      
   }
      
   return carts_;
}


//////////////////////////////////////////////////////////////////
// Return the player's cart.
- (TECart *)playerCart;
{
   TECart *result = nil;
   NSArray *carts = [self carts];
   
   if(0 < carts.count)
   {
      result = [carts objectAtIndex:0];
   }
   
   return result;
}


//////////////////////////////////////////////////////////////////
// The fraction of terrain in-set where carts are excluded
static const GLfloat TEExcludedZoneFraction = (0.04f);

//////////////////////////////////////////////////////////////////
// Set the velocity magnitude reasonably low after a "bounce"
static const GLfloat TEBounceVelocityMagnitude = (0.1f);


//////////////////////////////////////////////////////////////////
// This method keeps carts within the terrain area by making
// them bounce off imaginary edges of the terrain.
- (BOOL)cart:(TECart *)aCart
   willChangePosition:(GLKVector3 *)positionPtr;
{
   if(NULL != positionPtr)
   {
      if(positionPtr->x > (self.terrain.widthMeters * 
            (1.0f - TEExcludedZoneFraction)))
      {
         GLKVector3 velocity = GLKVector3Make(-aCart.velocity.x,
            aCart.velocity.y, aCart.velocity.z);
         *positionPtr = GLKVector3Add(*positionPtr,
            GLKVector3MultiplyScalar(
               GLKVector3Normalize(velocity), 
               TEBounceVelocityMagnitude));
         positionPtr->x = (self.terrain.widthMeters * 
            (1.0f - TEExcludedZoneFraction));
      }
      else if(positionPtr->x < (self.terrain.widthMeters * 
            TEExcludedZoneFraction))
      {
         GLKVector3 velocity = GLKVector3Make(-aCart.velocity.x,
            aCart.velocity.y, aCart.velocity.z);
         *positionPtr = GLKVector3Add(*positionPtr,
            GLKVector3MultiplyScalar(
               GLKVector3Normalize(velocity), 
               TEBounceVelocityMagnitude));
         positionPtr->x = (self.terrain.widthMeters * 
            TEExcludedZoneFraction);
      } 
      
      if(positionPtr->z > (self.terrain.lengthMeters * 
            (1.0f - TEExcludedZoneFraction)))
      {
         GLKVector3 velocity = GLKVector3Make(aCart.velocity.x,
            aCart.velocity.y, -aCart.velocity.z);
         *positionPtr = GLKVector3Add(*positionPtr,
            GLKVector3MultiplyScalar(
               GLKVector3Normalize(velocity), 
               TEBounceVelocityMagnitude));
         positionPtr->z = (self.terrain.lengthMeters * 
            (1.0f - TEExcludedZoneFraction));
      }
      else if(positionPtr->z < (self.terrain.lengthMeters * 
            TEExcludedZoneFraction))
      {
         GLKVector3 velocity = GLKVector3Make(aCart.velocity.x,
            aCart.velocity.y, -aCart.velocity.z);
         *positionPtr = GLKVector3Add(*positionPtr,
            GLKVector3MultiplyScalar(
               GLKVector3Normalize(velocity), 
               TEBounceVelocityMagnitude));
         positionPtr->z = (self.terrain.lengthMeters * 
            TEExcludedZoneFraction);
      }
   }
         
   return YES;
}

@end
