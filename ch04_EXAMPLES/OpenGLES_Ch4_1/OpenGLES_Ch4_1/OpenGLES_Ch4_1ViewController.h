//
//  OpenGLES_Ch4_1ViewController.h
//  OpenGLES_Ch4_1
//

#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;


@interface OpenGLES_Ch4_1ViewController : GLKViewController

@property (strong, nonatomic) GLKBaseEffect 
   *baseEffect;
@property (strong, nonatomic) GLKBaseEffect 
   *extraEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *extraBuffer;

@property (nonatomic) GLfloat
   centerVertexHeight;
@property (nonatomic) BOOL
   shouldUseFaceNormals;
@property (nonatomic) BOOL
   shouldDrawNormals;

- (IBAction)takeShouldUseFaceNormalsFrom:(UISwitch *)sender;
- (IBAction)takeShouldDrawNormalsFrom:(UISwitch *)sender;
- (IBAction)takeCenterVertexHeightFrom:(UISlider *)sender;

@end
