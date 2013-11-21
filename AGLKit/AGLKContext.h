//
//  GLKContext.h
//  
//

#import <GLKit/GLKit.h>

@interface AGLKContext : EAGLContext
{
   GLKVector4 clearColor;
}

@property (nonatomic, assign, readwrite) 
   GLKVector4 clearColor;

- (void)clear:(GLbitfield)mask;
- (void)enable:(GLenum)capability;
- (void)disable:(GLenum)capability;
- (void)setBlendSourceFunction:(GLenum)sfactor 
   destinationFunction:(GLenum)dfactor;
   
@end
