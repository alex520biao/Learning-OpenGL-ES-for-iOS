//
//  OpenGLES_Ch5_2ViewController.h
//  OpenGLES_Ch5_2
//

#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;


@interface OpenGLES_Ch5_2ViewController : GLKViewController

@property (strong, nonatomic) GLKBaseEffect 
   *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexPositionBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexNormalBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexTextureCoordBuffer;

@end
