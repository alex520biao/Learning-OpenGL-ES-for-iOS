//
//  OpenGLES_Ch6_4ViewController.h
//  OpenGLES_Ch6_4
//

#import <GLKit/GLKit.h>

@class AGLKTextureTransformBaseEffect;
@class SceneAnimatedMesh;
@class SceneCanLightModel;


@interface OpenGLES_Ch6_4ViewController : GLKViewController

@property (strong, nonatomic) AGLKTextureTransformBaseEffect 
   *baseEffect;
@property (strong, nonatomic) SceneAnimatedMesh 
   *animatedMesh;
@property (strong, nonatomic) SceneCanLightModel 
   *canLightModel;
@property (nonatomic, assign) GLfloat 
   spotLight0TiltAboutXAngleDeg;
@property (nonatomic, assign) GLfloat 
   spotLight0TiltAboutZAngleDeg;
@property (nonatomic, assign) GLfloat 
   spotLight1TiltAboutXAngleDeg;
@property (nonatomic, assign) GLfloat 
   spotLight1TiltAboutZAngleDeg;

@end
