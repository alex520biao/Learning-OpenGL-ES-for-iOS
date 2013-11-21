//
//  OpenGLES_Ch6_1ViewController.h
//  OpenGLES_Ch6_1
//

#import <GLKit/GLKit.h>
#import "SceneCar.h"


@interface OpenGLES_Ch6_1ViewController : GLKViewController
   <SceneCarControllerProtocol>

@property (readonly, nonatomic, strong) NSArray  
   *cars;
@property (readonly, nonatomic, assign) 
   SceneAxisAllignedBoundingBox rinkBoundingBox;

@end
