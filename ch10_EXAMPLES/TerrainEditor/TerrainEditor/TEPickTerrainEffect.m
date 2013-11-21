//
//  TEPickTerrainEffect.m
//  
//

#import "TEPickTerrainEffect.h"
#import "TETerrain+modelAdditions.h"
#import "TEModelPlacement.h"
#import "TEModelManager.h"
#import "TEModel.h"


/////////////////////////////////////////////////////////////////
// TEXTURE
/////////////////////////////////////////////////////////////////
#define MAX_TEXTURES    1
#define MAX_TEX_COORDS  1

/////////////////////////////////////////////////////////////////
// GLSL program uniform indices.
enum
{
   TEPickTerrainMVPMatrix,
   TEPickTerrainDimensionFactors,
   TEPickTerrainModelIndex,
   TEPickModelSamplers2D,
   TEPickTerrainNumUniforms
};


@interface TEPickTerrainEffect ()
{
   GLuint program;
   GLint uniforms[TEPickTerrainNumUniforms];
   GLuint pickFBO;
}

@property(assign, nonatomic, readwrite) UtilityVector2 factors;
@property(assign, nonatomic, readwrite) GLfloat width;
@property(assign, nonatomic, readwrite) GLfloat length;

-(GLuint)buildFBOWithWidth:(GLuint)width height:(GLuint)height;
-(void)destroyFBO:(GLuint)fboName;

@end


@implementation TEPickTerrainEffect

@synthesize projectionMatrix;
@synthesize modelviewMatrix;
@synthesize modelIndex;
@synthesize texture2D;
@synthesize factors;
@synthesize width;
@synthesize length;

/////////////////////////////////////////////////////////////////
// Designated Initializer 
- (id)initWithTerrain:(TETerrain *)aTerrain;
{
   NSParameterAssert(nil != aTerrain);
   NSParameterAssert(0.0f < aTerrain.widthMeters);
   NSParameterAssert(0.0f < aTerrain.lengthMeters);
   
   if(nil != (self = [super init]))
   {
      self.factors = UtilityVector2Make(
         1.0f / aTerrain.widthMeters,
         1.0f / aTerrain.lengthMeters);
      self.width = [aTerrain.width floatValue];
      self.length = [aTerrain.length floatValue];
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//  Invalid initializer
- (id)init;
{
   NSAssert(0, @"Invalid initializer");
   [self release];
   self = nil;
   
   return self;
}


/////////////////////////////////////////////////////////////////
//  
- (void)dealloc
{
	[self destroyFBO:pickFBO];
   
   [super dealloc];
}


#pragma mark -  OpenGL ES 2 shader compilation

/////////////////////////////////////////////////////////////////
// 
- (void)bindAttribLocations;
{
   glBindAttribLocation(
      self.program, 
      TEPickPositionAttrib, 
      "a_position");
   glBindAttribLocation(
      self.program, 
      TEPickModelTexCoords0Attrib, 
      "a_texCoords0");
}


/////////////////////////////////////////////////////////////////
// 
- (void)configureUniformLocations;
{
   uniforms[TEPickTerrainMVPMatrix] = glGetUniformLocation(
      self.program, 
      "u_mvpMatrix");
   uniforms[TEPickTerrainDimensionFactors] = glGetUniformLocation(
      self.program, 
      "u_dimensionFactors");
   uniforms[TEPickTerrainModelIndex] = glGetUniformLocation(
      self.program, 
      "u_modelIndex");
   uniforms[TEPickModelSamplers2D] = glGetUniformLocation(
      self.program, 
      "u_units");
}


#pragma mark -  Render Support

/////////////////////////////////////////////////////////////////
//
-(void)deleteFBOAttachment:(GLenum)attachment
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


/////////////////////////////////////////////////////////////////
//
-(void)destroyFBO:(GLuint)fboName
{ 
   if(0 == fboName)
   {
      return;
   }
    
   glBindFramebuffer(GL_FRAMEBUFFER, fboName);

   GLint maxColorAttachments = 1;
   glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS, &maxColorAttachments);

   // For every color buffer attached
   for(GLint colorAttachment = 0; 
      colorAttachment < maxColorAttachments; 
      colorAttachment++)
   {
      // Delete the attachment
      [self deleteFBOAttachment:
         (GL_COLOR_ATTACHMENT0+colorAttachment)];
   }

   // Delete any depth or stencil buffer attached
   [self deleteFBOAttachment:GL_DEPTH_ATTACHMENT];
   [self deleteFBOAttachment:GL_STENCIL_ATTACHMENT];

   glDeleteFramebuffers(1, &fboName);
}


/////////////////////////////////////////////////////////////////
//
-(GLuint)buildFBOWithWidth:(GLuint)fboWidth height:(GLuint)fboHeight
{
	GLuint fboName;	
	GLuint colorTexture;
	
	// Create a texture object to apply to model
	glGenTextures(1, &colorTexture);
	glBindTexture(GL_TEXTURE_2D, colorTexture);
	
	// Set up filter and wrap modes for this texture object
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	
	// Allocate a texture image we can render to
	// Pass NULL for the data parameter since we don't need to load image data.
	//     We will be generating the image by rendering to this texture
	glTexImage2D(
      GL_TEXTURE_2D, 
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
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, fboWidth, fboHeight);
	
	glGenFramebuffers(1, &fboName);
	glBindFramebuffer(GL_FRAMEBUFFER, fboName);	
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, colorTexture, 0);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
	
	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
		[self destroyFBO:fboName];
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
   [self loadShadersWithName:@"PickTerrainShader"];
   
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
   UtilityMatrix4 modelViewProjectionMatrix = 
      UtilityMatrix4Multiply(
         self.projectionMatrix, 
         self.modelviewMatrix);
   
   // Standard matrices
   glUniformMatrix4fv(uniforms[TEPickTerrainMVPMatrix], 1, 0, 
      modelViewProjectionMatrix.m);

   glUniform2fv(uniforms[TEPickTerrainDimensionFactors], 1, 
      self.factors.v);
      
   glUniform1f(uniforms[TEPickTerrainModelIndex], 
      self.modelIndex / 255.0f);
      
   const GLint   samplerIDs[MAX_TEXTURES] = {0};
   glUniform1iv(uniforms[TEPickModelSamplers2D], MAX_TEXTURES, 
      samplerIDs); 
}


/////////////////////////////////////////////////////////////////
//  
- (void)prepareToDraw;
{
   [super prepareToDraw];
   glBindFramebuffer(GL_FRAMEBUFFER, pickFBO);
   glViewport(0, 0, TEPickTerrainFBOWidth, 
      TEPickTerrainFBOHeight);

   // bind textures
   glActiveTexture(GL_TEXTURE0);
   if(nil != self.texture2D)
   {
      glBindTexture(GL_TEXTURE_2D, self.texture2D.name);
   }
   else
   {
      glBindTexture(GL_TEXTURE_2D, 0);
   }
}


/////////////////////////////////////////////////////////////////
//  
- (TEPickTerrainInfo)positionAtMouseLocation:
   (UtilityVector2)mouseLocation
   aspectRatio:(GLfloat)anAspectRatio;
{
   NSParameterAssert(0.0 < anAspectRatio);
   
   //NSLog(@"{%f, %f}", mouseLocation.x, mouseLocation.y);
   
   GLubyte pixelColor[4];
   GLint readLocationX = MIN((TEPickTerrainFBOWidth - 1),
      (TEPickTerrainFBOWidth - 2) * mouseLocation.x);
   GLint readLocationY = MIN((TEPickTerrainFBOHeight - 1),
      (TEPickTerrainFBOHeight - 2) * mouseLocation.y);
   glReadPixels(readLocationX,
      readLocationY, 
      1, 
      1, 
      GL_RGBA,
      GL_UNSIGNED_BYTE, 
      pixelColor);   

   //NSLog(@"{%d, %d, %d}", pixelColor[0], pixelColor[1], pixelColor[2]);

#ifdef DEBUG
   {  // Report any errors 
      GLenum error = glGetError();
      if(GL_NO_ERROR != error)
      {
         NSLog(@"GL Error: 0x%x", error);
      }
   }
#endif
   
   /*****/
   {
      NSMutableData *imageData =
         [NSMutableData dataWithLength:(
            TEPickTerrainFBOWidth * TEPickTerrainFBOHeight * 4)];
      glReadPixels(0,
         0, 
         TEPickTerrainFBOWidth, 
         TEPickTerrainFBOHeight, 
         GL_RGBA,
         GL_UNSIGNED_BYTE, 
         [imageData mutableBytes]);
         
      // Create image from data buffer
      CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGBLinear);
      CGContextRef cgContext = CGBitmapContextCreate( 
         [imageData mutableBytes], 
         TEPickTerrainFBOWidth, 
         TEPickTerrainFBOHeight, 
         8, 
         4 * TEPickTerrainFBOWidth, 
         colorSpace, 
         kCGImageAlphaNoneSkipLast);
      CGColorSpaceRelease(colorSpace);
      
      CGImageRef imageRef = CGBitmapContextCreateImage(
         cgContext);
      CGContextRelease(cgContext);
      
      [[[[[NSBitmapImageRep alloc] initWithCGImage:imageRef] autorelease] TIFFRepresentation]
         writeToFile:[@"~/pick.tiff" stringByExpandingTildeInPath] 
         atomically:YES];
      CGImageRelease(imageRef);
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
   /*****/
   
   TEPickTerrainInfo result;
   UtilityVector2 position = {
      self.width * (float)pixelColor[0] / 
         TEPickTerrainMaxIndex,
      self.length * (float)pixelColor[1] / 
         TEPickTerrainMaxIndex
   };
   result.position = position;
   result.modelIndex = pixelColor[2];
   
   return result;
}

@end
