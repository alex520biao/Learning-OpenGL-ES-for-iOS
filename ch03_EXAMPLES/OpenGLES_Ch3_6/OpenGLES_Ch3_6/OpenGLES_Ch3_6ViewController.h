//
//  OpenGLES_Ch3_6ViewController.h
//  OpenGLES_Ch3_6
//

#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;


@interface OpenGLES_Ch3_6ViewController : GLKViewController
{
   GLuint _program;
   
   GLKMatrix4 _modelViewProjectionMatrix;
   GLKMatrix3 _normalMatrix;
   GLfloat _rotation;
   
   GLuint _vertexArray;
   GLuint _vertexBuffer;
   GLuint _texture0ID;
   GLuint _texture1ID;
}

@property (strong, nonatomic) GLKBaseEffect 
   *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexBuffer;

@end
