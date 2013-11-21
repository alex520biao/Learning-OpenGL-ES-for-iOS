//
//  OpenGLES_Ch2_2ViewController.h
//  OpenGLES_Ch2_2
//

#import "AGLKViewController.h"
#import <GLKit/GLKit.h>

@interface OpenGLES_Ch2_2ViewController : AGLKViewController
{
   GLuint vertexBufferID;
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect;

@end
