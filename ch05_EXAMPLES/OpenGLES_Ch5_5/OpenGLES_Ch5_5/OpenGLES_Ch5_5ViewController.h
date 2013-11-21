//
//  OpenGLES_Ch5_5ViewController.h
//  OpenGLES_Ch5_5
//

#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;
@class AGLKTextureTransformBaseEffect;


@interface OpenGLES_Ch5_5ViewController : GLKViewController

@property (strong, nonatomic) AGLKTextureTransformBaseEffect 
   *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexBuffer;
@property (nonatomic) float 
   textureScaleFactor;
@property (nonatomic) float 
   textureAngle;
@property (nonatomic) GLKMatrixStackRef 
   textureMatrixStack;

// Methods called from user interface objects configured
// in Interface Builder
- (IBAction)takeTextureScaleFactorFrom:(UISlider *)aControl;
- (IBAction)takeTextureAngleFrom:(UISlider *)aControl;

@end
