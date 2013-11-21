//
//  OpenGLES_Ch3_5ViewController.h
//  OpenGLES_Ch3_5
//

#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;


@interface OpenGLES_Ch3_5ViewController : GLKViewController
{
}

@property (strong, nonatomic) GLKBaseEffect 
   *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexBuffer;

@end
