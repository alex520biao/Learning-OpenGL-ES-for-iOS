//
//  OpenGLES_Ch4_2ViewController.h
//  OpenGLES_Ch4_2
//

#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;


@interface OpenGLES_Ch4_2ViewController : GLKViewController

@property (strong, nonatomic) GLKBaseEffect 
   *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexBuffer;
@property (strong, nonatomic) GLKTextureInfo 
   *blandTextureInfo;
@property (strong, nonatomic) GLKTextureInfo 
   *interestingTextureInfo;
@property (nonatomic) BOOL 
   shouldUseDetailLighting;

- (IBAction)takeShouldUseDetailLightingFrom:(UISwitch *)sender;

@end
