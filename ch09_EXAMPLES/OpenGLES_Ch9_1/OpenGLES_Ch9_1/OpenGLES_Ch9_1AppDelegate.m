//
//  OpenGLES_Ch9_1AppDelegate.m
//  OpenGLES_Ch9_1
//

#import "OpenGLES_Ch9_1AppDelegate.h"


@interface OpenGLES_Ch9_1AppDelegate ()

@property (strong, nonatomic, readwrite) CMMotionManager *motionManager;

@end


@implementation OpenGLES_Ch9_1AppDelegate

@synthesize window = _window;
@synthesize motionManager = motionManager_;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Stop device motion updates
   [self.motionManager stopDeviceMotionUpdates];
   [self.motionManager stopAccelerometerUpdates];
   self.motionManager = nil;
   
   /*
    Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   /*
    Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
   /*
    Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[application setStatusBarHidden:YES 
      withAnimation:UIStatusBarAnimationFade];

	// Configure to receive device motion updates
   self.motionManager = [[CMMotionManager alloc] init];
   [self.motionManager startDeviceMotionUpdates];
   [self.motionManager startAccelerometerUpdates];
      
   /*
    Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
   /*
    Called when the application is about to terminate.
    Save data if appropriate.
    See also applicationDidEnterBackground:.
    */
}

@end
