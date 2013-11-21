//
//  OpenGLES_Ch3_1ViewController.h
//  OpenGLES_Ch3_1
//

#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;


@interface OpenGLES_Ch3_1ViewController : GLKViewController
{
}

@property (strong, nonatomic) GLKBaseEffect 
   *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexBuffer;

@end
