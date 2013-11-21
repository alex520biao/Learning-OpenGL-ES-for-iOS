//
//  AGLKView.m
//  
//

#import "AGLKView.h"
#import <QuartzCore/QuartzCore.h>


@implementation AGLKView

@synthesize delegate;
@synthesize context;
@synthesize drawableDepthFormat;

/////////////////////////////////////////////////////////////////
// This method returns the CALayer subclass to be used by  
// CoreAnimation with this view
+ (Class)layerClass
{
   return [CAEAGLLayer class];
}


/////////////////////////////////////////////////////////////////
// This method is designated initializer for the class 
- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)aContext;
{
   if ((self = [super initWithFrame:frame]))
   {
      CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
      
      eaglLayer.drawableProperties = 
         [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithBool:NO], 
             kEAGLDrawablePropertyRetainedBacking, 
             kEAGLColorFormatRGBA8, 
             kEAGLDrawablePropertyColorFormat, 
             nil];
      
      self.context = aContext;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// This method is called automatically to initialize each Cocoa
// Touch object as the object is unarchived from an 
// Interface Builder .xib or .storyboard file.
- (id)initWithCoder:(NSCoder*)coder
{    
   if ((self = [super initWithCoder:coder]))
   {
      CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
      
      eaglLayer.drawableProperties = 
         [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithBool:NO], 
             kEAGLDrawablePropertyRetainedBacking, 
             kEAGLColorFormatRGBA8, 
             kEAGLDrawablePropertyColorFormat, 
             nil];          
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// This method sets the receiver's OpenGL ES Context. If the 
// receiver already has a different Context, this method deletes
// OpenGL ES Frame Buffer resources in the old Context and the 
// recreates them in the new Context.
- (void)setContext:(EAGLContext *)aContext
{
   if(context != aContext)
   {  // Delete any buffers previously created in old Context
      [EAGLContext setCurrentContext:context];
      
      if (0 != defaultFrameBuffer)
      {
         glDeleteFramebuffers(1, &defaultFrameBuffer); // Step 7
         defaultFrameBuffer = 0;
      }
      
      if (0 != colorRenderBuffer)
      {
         glDeleteRenderbuffers(1, &colorRenderBuffer); // Step 7
         colorRenderBuffer = 0;
      }
      
      if (0 != depthRenderBuffer)
      {
         glDeleteRenderbuffers(1, &depthRenderBuffer); // Step 7
         depthRenderBuffer = 0;
      }
      
      context = aContext;
   
      if(nil != context)
      {  // Configure the new Context with required buffers
         context = aContext;
         [EAGLContext setCurrentContext:context];
                   
         glGenFramebuffers(1, &defaultFrameBuffer);    // Step 1
         glBindFramebuffer(                            // Step 2
            GL_FRAMEBUFFER,             
            defaultFrameBuffer);

         glGenRenderbuffers(1, &colorRenderBuffer);    // Step 1
         glBindRenderbuffer(                           // Step 2
            GL_RENDERBUFFER, 
            colorRenderBuffer);
         
         // Attach color render buffer to bound Frame Buffer
         glFramebufferRenderbuffer(
            GL_FRAMEBUFFER, 
            GL_COLOR_ATTACHMENT0, 
            GL_RENDERBUFFER, 
            colorRenderBuffer);

         // Create any additional render buffers based on the
         // drawable size of defaultFrameBuffer
         [self layoutSubviews];
      }
   }
}


/////////////////////////////////////////////////////////////////
// This method returns the receiver's OpenGL ES Context
- (EAGLContext *)context
{
   return context;
}


/////////////////////////////////////////////////////////////////
// Calling this method tells the receiver to redraw the contents 
// of its associated OpenGL ES Frame Buffer. This method 
// configures OpenGL ES and then calls -drawRect:
- (void)display;
{
   [EAGLContext setCurrentContext:self.context];
   glViewport(0, 0, self.drawableWidth, self.drawableHeight);

   [self drawRect:[self bounds]];
   
   [self.context presentRenderbuffer:GL_RENDERBUFFER];
}


/////////////////////////////////////////////////////////////////
// This method is called automatically whenever the receiver
// needs to redraw the contents of its associated OpenGL ES
// Frame Buffer. This method should not be called directly. Call
// -display instead which configures OpenGL ES before calling
// -drawRect:
- (void)drawRect:(CGRect)rect
{
   if(delegate)
   {
      [self.delegate glkView:self drawInRect:[self bounds]];
   }
}


/////////////////////////////////////////////////////////////////
// This method is called automatically whenever a UIView is 
// resized including just after the view is added to a UIWindow. 
- (void)layoutSubviews
{
   CAEAGLLayer 	*eaglLayer = (CAEAGLLayer *)self.layer;
   
   // Make sure our context is current
   [EAGLContext setCurrentContext:self.context];

   // Initialize the current Frame Buffer’s pixel color buffer 
   // so that it shares the corresponding Core Animation Layer’s
   // pixel color storage.
   [self.context renderbufferStorage:GL_RENDERBUFFER 
      fromDrawable:eaglLayer];
      
   
   if (0 != depthRenderBuffer)
   {
      glDeleteRenderbuffers(1, &depthRenderBuffer); // Step 7
      depthRenderBuffer = 0;
   }
   
   GLint currentDrawableWidth = self.drawableWidth;
   GLint currentDrawableHeight = self.drawableHeight;
   
   if(self.drawableDepthFormat != 
      AGLKViewDrawableDepthFormatNone &&
      0 < currentDrawableWidth &&
      0 < currentDrawableHeight)
   {
      glGenRenderbuffers(1, &depthRenderBuffer); // Step 1
      glBindRenderbuffer(GL_RENDERBUFFER,        // Step 2
         depthRenderBuffer);
      glRenderbufferStorage(GL_RENDERBUFFER,     // Step 3 
         GL_DEPTH_COMPONENT16, 
         currentDrawableWidth, 
         currentDrawableHeight);
      glFramebufferRenderbuffer(GL_FRAMEBUFFER,  // Step 4 
         GL_DEPTH_ATTACHMENT, 
         GL_RENDERBUFFER, 
         depthRenderBuffer);
   }
   
   // Check for any errors configuring the render buffer   
   GLenum status = glCheckFramebufferStatus(
      GL_FRAMEBUFFER) ;
     
   if(status != GL_FRAMEBUFFER_COMPLETE) {
       NSLog(@"failed to make complete frame buffer object %x", status);
   }

   // Make the Color Render Buffer the current buffer for display
   glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
}


/////////////////////////////////////////////////////////////////
// This method returns the width in pixels of current context's
// Pixel Color Render Buffer
- (NSInteger)drawableWidth;
{
   GLint          backingWidth;

   glGetRenderbufferParameteriv(
      GL_RENDERBUFFER, 
      GL_RENDERBUFFER_WIDTH, 
      &backingWidth);
      
   return (NSInteger)backingWidth;
}


/////////////////////////////////////////////////////////////////
// This method returns the height in pixels of current context's
// Pixel Color Render Buffer
- (NSInteger)drawableHeight;
{
   GLint          backingHeight;

   glGetRenderbufferParameteriv(
      GL_RENDERBUFFER, 
      GL_RENDERBUFFER_HEIGHT, 
      &backingHeight);
      
   return (NSInteger)backingHeight;
}


/////////////////////////////////////////////////////////////////
// This method is called automatically when the reference count 
// for a Cocoa Touch object reaches zero.
- (void)dealloc
{
   // Make sure the receiver's OpenGL ES Context is not current
   if ([EAGLContext currentContext] == context)
   {
      [EAGLContext setCurrentContext:nil];
   }

   // Deletes the receiver's OpenGL ES Context
   context = nil;
}

@end
