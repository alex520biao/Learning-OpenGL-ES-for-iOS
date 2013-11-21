//
//  OpenGLES_Ch2_2ViewController.m
//  OpenGLES_Ch2_2
//

#import "OpenGLES_Ch2_2ViewController.h"

@implementation OpenGLES_Ch2_2ViewController

@synthesize baseEffect;

/////////////////////////////////////////////////////////////////
// This data type is used to store information for each vertex
typedef struct {
   GLKVector3  positionCoords;
}
SceneVertex;

/////////////////////////////////////////////////////////////////
// Define vertex data for a triangle to use in example
static const SceneVertex vertices[] = 
{
   {{-0.5f, -0.5f, 0.0}}, // lower left corner
   {{ 0.5f, -0.5f, 0.0}}, // lower right corner
   {{-0.5f,  0.5f, 0.0}}  // upper left corner
};


/////////////////////////////////////////////////////////////////
// Called when the view controller's view is loaded
// Perform initialization before the view is asked to draw
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   // Verify the type of view created automatically by the
   // Interface Builder storyboard
   AGLKView *view = (AGLKView *)self.view;
   NSAssert([view isKindOfClass:[AGLKView class]],
      @"View controller's view is not a AGLKView");
   
   // Create an OpenGL ES 2.0 context and provide it to the
   // view
   view.context = [[EAGLContext alloc] 
      initWithAPI:kEAGLRenderingAPIOpenGLES2];
   
   // Make the new context current
   [EAGLContext setCurrentContext:view.context];
   
   // Create a base effect that provides standard OpenGL ES 2.0
   // shading language programs and set constants to be used for 
   // all subsequent rendering
   self.baseEffect = [[GLKBaseEffect alloc] init];
   self.baseEffect.useConstantColor = GL_TRUE;
   self.baseEffect.constantColor = GLKVector4Make(
      1.0f, // Red
      1.0f, // Green
      1.0f, // Blue
      1.0f);// Alpha
   
   // Set the background color stored in the current context 
   glClearColor(0.0f, 0.0f, 0.0f, 1.0f); // background color
   
   // Generate, bind, and initialize contents of a buffer to be 
   // stored in GPU memory
   glGenBuffers(1,                // STEP 1
      &vertexBufferID);
   glBindBuffer(GL_ARRAY_BUFFER,  // STEP 2
      vertexBufferID); 
   glBufferData(                  // STEP 3
      GL_ARRAY_BUFFER,  // Initialize buffer contents
      sizeof(vertices), // Number of bytes to copy
      vertices,         // Address of bytes to copy
      GL_STATIC_DRAW);  // Hint: cache in GPU memory
}


/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect
{
   [self.baseEffect prepareToDraw];
   
   // Clear back frame buffer (erase previous drawing)
   glClear(GL_COLOR_BUFFER_BIT);
   
   // Enable use of positions from bound vertex buffer
   glEnableVertexAttribArray(      // STEP 4
      GLKVertexAttribPosition);
      
   glVertexAttribPointer(          // STEP 5
      GLKVertexAttribPosition, 
      3,                   // three components per vertex
      GL_FLOAT,            // data is floating point
      GL_FALSE,            // no fixed point scaling
      sizeof(SceneVertex), // no gaps in data
      NULL);               // NULL tells GPU to start at 
                           // beginning of bound buffer
                                   
   // Draw triangles using the first three vertices in the 
   // currently bound vertex buffer
   glDrawArrays(GL_TRIANGLES,      // STEP 6
      0,  // Start with first vertex in currently bound buffer
      3); // Use three vertices from currently bound buffer
}


/////////////////////////////////////////////////////////////////
// Called when the view controller's view has been unloaded
// Perform clean-up that is possible when you know the view 
// controller's view won't be asked to draw again soon.
- (void)viewDidUnload
{
   [super viewDidUnload];
   
   // Delete buffers that aren't needed when view is unloaded
   if (0 != vertexBufferID)
   {
      glDeleteBuffers (1,          // STEP 7 
                       &vertexBufferID);  
      vertexBufferID = 0;
   }
   
   // Stop using the context created in -viewDidLoad
   ((AGLKView *)self.view).context = nil;
   [EAGLContext setCurrentContext:nil];
}

@end
