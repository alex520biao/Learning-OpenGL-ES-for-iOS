//
//  OpenGLES_Ch10_2AppDelegate.m
//  OpenGLES_Ch10_2
//

#import "OpenGLES_Ch10_2AppDelegate.h"
#import "TETerrain+viewAdditions.h"
#import "UtilityModelManager.h"


@interface OpenGLES_Ch10_2AppDelegate ()

@property (strong, nonatomic, readwrite) TETerrain *terrain;

@end


/////////////////////////////////////////////////////////////////
// 
@implementation OpenGLES_Ch10_2AppDelegate

@synthesize terrain;
@synthesize modelManager;
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
       URLForResource:@"OpenGLES_Ch10_2" withExtension:@"momd"];
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
   if(modelManager == nil &&
      nil != self.terrain.modelsData)
   {
      modelManager = [[UtilityModelManager alloc] init];
      [modelManager readFromData:self.terrain.modelsData 
         ofType:nil 
         error:NULL];
   }
      
   return modelManager;
}

@end
