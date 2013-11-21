//
//  ViewController.h
//  OpenGLES_Ch3_3
//

#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;


@interface OpenGLES_Ch3_3ViewController : GLKViewController
{
}

@property (strong, nonatomic) GLKBaseEffect 
   *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexBuffer;
@property (nonatomic) BOOL 
   shouldUseLinearFilter;
@property (nonatomic) BOOL 
   shouldAnimate;
@property (nonatomic) BOOL 
   shouldRepeatTexture;
@property (nonatomic) GLfloat 
   sCoordinateOffset;

- (IBAction)takeSCoordinateOffsetFrom:(UISlider *)sender;
- (IBAction)takeShouldRepeatTextureFrom:(UISwitch *)sender;
- (IBAction)takeShouldAnimateFrom:(UISwitch *)sender;
- (IBAction)takeShouldUseLinearFilterFrom:(UISwitch *)sender;

@end
