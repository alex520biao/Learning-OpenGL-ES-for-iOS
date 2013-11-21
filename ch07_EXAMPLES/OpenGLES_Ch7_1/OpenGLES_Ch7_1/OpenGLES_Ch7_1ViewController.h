//
//  OpenGLES_Ch7_1ViewController.h
//  OpenGLES_Ch7_1
//

#import <GLKit/GLKit.h>
#import "SceneCar.h"


@interface OpenGLES_Ch7_1ViewController : GLKViewController
   <SceneCarControllerProtocol>

@property (readonly, nonatomic, strong) NSArray  
   *cars;
@property (readonly, nonatomic, assign) 
   AGLKAxisAllignedBoundingBox rinkBoundingBox;

@end
   
