//
//  OpenGLES_Ch9_1AppDelegate.h
//  OpenGLES_Ch9_1
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>


@interface OpenGLES_Ch9_1AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) CMMotionManager *motionManager;

@end
