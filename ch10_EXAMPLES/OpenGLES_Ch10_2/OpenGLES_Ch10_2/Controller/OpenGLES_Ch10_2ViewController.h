//
//  OpenGLES_Ch10_2ViewController.h
//  OpenGLES_Ch10_2
//

#import <GLKit/GLKit.h>

@class UtilityCamera;
@class UtilityTerrainEffect;
@class UtilityModelManager;
@class TETerrain;


@protocol OpenGLES_Ch10_2ViewDataSourceProtocol <NSObject>

- (TETerrain *)terrain;
- (UtilityModelManager *)modelManager;
- (NSManagedObjectContext *)managedObjectContext;

@end


@interface OpenGLES_Ch10_2ViewController : GLKViewController
   <UIGestureRecognizerDelegate>

@property (strong, nonatomic, readonly) 
   UtilityTerrainEffect *terrainEffect;
@property (strong, nonatomic, readonly) 
   UtilityCamera *camera;
   
@property (strong, nonatomic, readwrite) 
   IBOutlet id <OpenGLES_Ch10_2ViewDataSourceProtocol> dataSource;
@property (strong, nonatomic) IBOutlet UILabel *fpsField;

@end
