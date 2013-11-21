//
//  OpenGLES_Ch12_1AppDelegate.h
//  OpenGLES_Ch12_1
//

#import <UIKit/UIKit.h>
#import "OpenGLES_Ch12_1ViewController.h"

@class TECart;


@interface OpenGLES_Ch12_1AppDelegate : UIResponder 
   <UIApplicationDelegate, 
    OpenGLES_Ch12_1ViewDataSourceProtocol,
    TECartDelegateProtocol>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic, readonly) 
   UtilityModelManager *modelManager;
@property (strong, nonatomic, readonly) 
   UtilityModelManager *playerModelManager;
@property (strong, nonatomic, readonly) 
   NSArray *carts;
@property (strong, nonatomic, readonly) 
   TECart *playerCart;
@property (strong, nonatomic, readonly) 
   TETerrain *terrain;

- (void)saveContext;

@end
