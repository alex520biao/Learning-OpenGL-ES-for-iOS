//
//  OpenGLES_Ch5_3ViewController.h
//  OpenGLES_Ch5_3
//

#import <GLKit/GLKit.h>
#import "AGLKViewController.h"

@class AGLKVertexAttribArrayBuffer;


@interface OpenGLES_Ch5_3ViewController : AGLKViewController

@property (strong, nonatomic) GLKBaseEffect 
   *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexPositionBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexNormalBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexTextureCoordBuffer;

@end
