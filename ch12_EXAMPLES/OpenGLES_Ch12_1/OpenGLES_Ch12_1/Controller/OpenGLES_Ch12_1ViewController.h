//
//  OpenGLES_Ch12_1ViewController.h
//  OpenGLES_Ch12_1
//

#import <GLKit/GLKit.h>
#import "TECart.h"

@class UtilityCamera;
@class UtilityTerrainEffect;
@class UtilityModelManager;
@class TETerrain;
@class UtilityBillboardParticleManager;


@protocol OpenGLES_Ch12_1ViewDataSourceProtocol <NSObject>

- (TETerrain *)terrain;
- (UtilityModelManager *)modelManager;
- (NSManagedObjectContext *)managedObjectContext;
- (UtilityModelManager *)playerModelManager;
- (NSArray *)carts;
- (TECart *)playerCart;

@end


@interface OpenGLES_Ch12_1ViewController : GLKViewController
   <UIGestureRecognizerDelegate,
   TECartControllerProtocol>

@property (strong, nonatomic, readwrite) 
   IBOutlet id <OpenGLES_Ch12_1ViewDataSourceProtocol> dataSource;
@property (strong, nonatomic) 
   IBOutlet UILabel *fpsField;

- (IBAction)startBoosting:(id)sender;
- (IBAction)stopBoosting:(id)sender;
- (IBAction)toggleFirstPersonPOV:(id)sender;

@end
