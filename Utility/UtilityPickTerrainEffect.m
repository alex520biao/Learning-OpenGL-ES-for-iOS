//
//  TEPickTerrainEffect.m
//  
//

#import "UtilityPickTerrainEffect.h"
#import "TETerrain+viewAdditions.h"
#import "TEModelPlacement.h"


/////////////////////////////////////////////////////////////////
// GLSL program uniform indices.
enum
{
   UtilityPickTerrainMVPMatrix,
   UtilityPickTerrainDimensionFactors,
   UtilityPickTerrainModelIndex,
   UtilityPickTerrainNumUniforms
};


@interface UtilityPickTerrainEffect ()
{
   GLuint program;
   GLint uniforms[UtilityPickTerrainNumUniforms];
   GLuint pickFBO;
}

@property(assign, nonatomic, readwrite) GLKVector2 factors;
@property(assign, nonatomic, readwrite) GLfloat width;
@property(assign, nonatomic, readwrite) GLfloat length;

-(GLuint)buildFBOWithWidth:(GLuint)width height:(GLuint)height;

@end


@implementation UtilityPickTerrainEffect

@synthesize projectionMatrix = projectionMatrix_;
@synthesize modelviewMatrix = modelviewMatrix_;
@synthesize modelIndex = modelIndex_;
@synthesize factors = factors_;
@synthesize width = width_;
@synthesize length = length_;

static void UtilityPickTerrainEffectDeleteFBOAttachment(
   GLenum attachment);
static void UtilityPickTerrainEffectDestroyFBO(GLuint fboName);


/////////////////////////////////////////////////////////////////
// Designated Initializer 
- (id)initWithTerrain:(TETerrain *)aTerrain;
{
   NSParameterAssert(nil != aTerrain);
   NSParameterAssert(0.0f < aTerrain.widthMeters);
   NSParameterAssert(0.0f < aTerrain.lengthMeters);
   
   if(nil != (self = [super init]))
   {
      self.factors = GLKVector2Make(
         1.0f / aTerrain.widthMeters,
         1.0f / aTerrain.lengthMeters);
      self.width = aTerrain.width;
      self.length = aTerrain.length;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//  Invalid initializer
- (id)init;
{
   NSAssert(0, @"Invalid initializer");
   self = nil;
   
   return self;
}


/////////////////////////////////////////////////////////////////
//  
- (void)dealloc
{
	UtilityPickTerrainEffectDestroyFBO(pickFBO);
}


#pragma mark -  OpenGL ES 2 shader compilation

/////////////////////////////////////////////////////////////////
// 
- (void)bindAttribLocations;
{
   glBindAttribLocation(
      self.program, 
      TETerrainPositionAttrib, 
      "a_position");
}


/////////////////////////////////////////////////////////////////
// 
- (void)configureUniformLocations;
{
   uniforms[UtilityPickTerrainMVPMatrix] = glGetUniformLocation(
      self.program, 
      "u_mvpMatrix");
   uniforms[UtilityPickTerrainDimensionFactors] = glGetUniformLocation(
      self.program, 
      "u_dimensionFactors");
   uniforms[UtilityPickTerrainModelIndex] = glGetUniformLocation(
      self.program, 
      "u_modelIndex");
}


#pragma mark -  Render Support

/////////////////////////////////////////////////////////////////
// Build a Frame Buffer Object with attached Pixel Color Render
// Buffer and Depth Buffer to receive the results of rendering
// in false color for picking.
-(GLuint)buildFBOWithWidth:(GLuint)fboWidth 
                    height:(GLuint)fboHeight
{
   GLuint fboName;	
   GLuint colorTexture;

   // Create a texture object to apply to model
   glGenTextures(1, &colorTexture);
   glBindTexture(GL_TEXTURE_2D, colorTexture);

   // Set up filter and wrap modes for this texture object
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, 
                   GL_CLAMP_TO_EDGE);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, 
                   GL_CLAMP_TO_EDGE);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, 
                   GL_LINEAR);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
                   GL_LINEAR_MIPMAP_LINEAR);

   // Allocate a texture image we can render into
   // Pass NULL for the data parameter since we don't need to 
   // load image data. We will be generating the image by 
   // rendering to this texture.
   glTexImage2D(GL_TEXTURE_2D, 
                0, 
                GL_RGBA, 
                fboWidth, 
                fboHeight, 
                0,
                GL_RGBA, 
                GL_UNSIGNED_BYTE, 
                NULL);

   GLuint depthRenderbuffer;
   glGenRenderbuffers(1, &depthRenderbuffer);
   glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
   glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, 
                         fboWidth, fboHeight);

   glGenFramebuffers(1, &fboName);
   glBindFramebuffer(GL_FRAMEBUFFER, fboName);	
   glFramebufferTexture2D(GL_FRAMEBUFFER, 
                          GL_COLOR_ATTACHMENT0, 
                          GL_TEXTURE_2D, colorTexture, 0);
   glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);

   if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != 
      GL_FRAMEBUFFER_COMPLETE)
   {
      NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
      UtilityPickTerrainEffectDestroyFBO(fboName);
      return 0;
   }

#ifdef DEBUG
   {  // Report any errors 
      GLenum error = glGetError();
      if(GL_NO_ERROR != error)
      {
         NSLog(@"GL Error: 0x%x", error);
      }
   }
#endif
	
	return fboName;
}


static const NSInteger TEPickTerrainFBOWidth = (512);
static const NSInteger TEPickTerrainFBOHeight = (512);
static const NSInteger TEPickTerrainMaxIndex = (255);

/////////////////////////////////////////////////////////////////
//
- (void)prepareOpenGL
{
   [self loadShadersWithName:@"UtilityPickTerrainShader"];
   
   if(0 == pickFBO)
   {
      pickFBO = [self buildFBOWithWidth:TEPickTerrainFBOWidth 
         height:TEPickTerrainFBOHeight];
   }
}


/////////////////////////////////////////////////////////////////
//
- (void)updateUniformValues
{
   // Pre-calculate the mvpMatrix
   GLKMatrix4 modelViewProjectionMatrix = 
      GLKMatrix4Multiply(
         self.projectionMatrix, 
         self.modelviewMatrix);
   
   // Standard matrices
   glUniformMatrix4fv(uniforms[UtilityPickTerrainMVPMatrix], 1, 0, 
      modelViewProjectionMatrix.m);

   glUniform2fv(uniforms[UtilityPickTerrainDimensionFactors], 1, 
      self.factors.v);
      
   glUniform1f(uniforms[UtilityPickTerrainModelIndex], 
      self.modelIndex / 255.0f);
}


/////////////////////////////////////////////////////////////////
// Prepare OpenGL state for rendering into the FBO 
- (void)prepareToDraw;
{
   [super prepareToDraw];
   glBindFramebuffer(GL_FRAMEBUFFER, pickFBO);
   glViewport(0, 0, TEPickTerrainFBOWidth, 
      TEPickTerrainFBOHeight);
}


/////////////////////////////////////////////////////////////////
// This method returns the 3D X,Z coordinates of any terrain 
// at aPosition. The aPosition coordinates must be in the range
// 0.0 to 1.0 corresponding to the relative location of aPosition
// within a Cocoa Touch view a.k.a. "projection" coordinates.   
- (TEPickTerrainInfo)terrainInfoForProjectionPosition:
   (GLKVector2)aPosition
{
   GLubyte pixelColor[4];  // Red, Green, Blue, Alpha color
   GLint readLocationX = MIN((TEPickTerrainFBOWidth - 1),
      (TEPickTerrainFBOWidth - 1) * aPosition.x);
   GLint readLocationY = MIN((TEPickTerrainFBOHeight - 1),
      (TEPickTerrainFBOHeight - 1) * aPosition.y);
   glReadPixels(readLocationX,
      readLocationY, 
      1, 
      1, 
      GL_RGBA,
      GL_UNSIGNED_BYTE, 
      pixelColor);   

#ifdef DEBUG
   {  // Report any errors 
      GLenum error = glGetError();
      if(GL_NO_ERROR != error)
      {
         NSLog(@"GL Error: 0x%x", error);
      }
   }
#endif
      
   TEPickTerrainInfo result;
   GLKVector2 position = {
      self.width * (GLfloat)pixelColor[0] /  // red component
         TEPickTerrainMaxIndex,
      self.length * (GLfloat)pixelColor[1] / // green component
         TEPickTerrainMaxIndex
   };
   result.position = position;
   result.modelIndex = pixelColor[2]; // blue component
   
   return result;
}


/////////////////////////////////////////////////////////////////
// This function deletes the specified FBO including all of its
// attachments and returns resources to OpenGL
static void UtilityPickTerrainEffectDestroyFBO(GLuint fboName)
{ 
   if(0 == fboName)
   {
      return;
   }
    
   glBindFramebuffer(GL_FRAMEBUFFER, fboName);

   // Delete the attachment
   UtilityPickTerrainEffectDeleteFBOAttachment(
      GL_COLOR_ATTACHMENT0);

   // Delete any depth or stencil buffer attached
   UtilityPickTerrainEffectDeleteFBOAttachment(
      GL_DEPTH_ATTACHMENT);

   glDeleteFramebuffers(1, &fboName);
}


/////////////////////////////////////////////////////////////////
// This function deletes the specified attachment and returns 
// resources to OpenGL
static void UtilityPickTerrainEffectDeleteFBOAttachment(
   GLenum attachment)
{    
   GLint param;
   GLuint objName;

   glGetFramebufferAttachmentParameteriv(
      GL_FRAMEBUFFER, 
      attachment,
      GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE,
      &param);

   if(GL_RENDERBUFFER == param)
   {
      glGetFramebufferAttachmentParameteriv(
         GL_FRAMEBUFFER, 
         attachment,
         GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,
         &param);

      objName = ((GLuint*)(&param))[0];
      glDeleteRenderbuffers(1, &objName);
   }
   else if(GL_TEXTURE == param)
   {
      glGetFramebufferAttachmentParameteriv(
         GL_FRAMEBUFFER, 
         attachment,
         GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,
         &param);

      objName = ((GLuint*)(&param))[0];
      glDeleteTextures(1, &objName);
   }
}

@end
