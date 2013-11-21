//
//  OpenGLES_Ch10_2AppDelegate.h
//  OpenGLES_Ch10_2
//

#import <UIKit/UIKit.h>
#import "OpenGLES_Ch10_2ViewController.h"

@interface OpenGLES_Ch10_2AppDelegate : UIResponder 
   <UIApplicationDelegate, 
   OpenGLES_Ch10_2ViewDataSourceProtocol>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic, readonly) 
   UtilityModelManager *modelManager;
@property (strong, nonatomic, readonly) 
   TETerrain *terrain;
@property (readonly, strong, nonatomic) 
   NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) 
   NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) 
   NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;

@end
