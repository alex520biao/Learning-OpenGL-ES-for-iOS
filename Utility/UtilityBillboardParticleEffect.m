//
//  BillboardParticleEffect.m
//  
//

#import "UtilityBillboardParticleEffect.h"

/////////////////////////////////////////////////////////////////
// TEXTURE
/////////////////////////////////////////////////////////////////
#define MAX_TEXTURES    1
#define MAX_TEX_COORDS  1

/////////////////////////////////////////////////////////////////
// UtilityBillboardParticleShader GLSL program uniform indices.
enum
{
   TEBillboardParticleMVPMatrix,
   TEBillboardParticleSamplers2D,
   TEBillboardParticleNumUniforms
};


@interface UtilityBillboardParticleEffect ()
{
   GLint uniforms[TEBillboardParticleNumUniforms];
}

@end


@implementation UtilityBillboardParticleEffect

@synthesize projectionMatrix = projectionMatrix_;
@synthesize modelviewMatrix = modelviewMatrix_;
@synthesize texture2D = texture2D_;


#pragma mark -  Lifecycle

/////////////////////////////////////////////////////////////////
//  
- (id)init;
{
   if(nil != (self = [super init]))
   {
      self.projectionMatrix = GLKMatrix4Identity;
      self.modelviewMatrix = GLKMatrix4Identity;
   }
   
   return self;
}


#pragma mark -  OpenGL ES 2 shader compilation

/////////////////////////////////////////////////////////////////
// 
- (void)bindAttribLocations;
{
   glBindAttribLocation(
      self.program, 
      UtilityVertexAttribPosition, 
      "a_position");
   glBindAttribLocation(
      self.program, 
      UtilityVertexAttribOpacity, 
      "a_opacity");
   glBindAttribLocation(
      self.program, 
      UtilityVertexAttribTexCoord0, 
      "a_texCoords0");
}


/////////////////////////////////////////////////////////////////
// 
- (void)configureUniformLocations;
{
   uniforms[TEBillboardParticleMVPMatrix] = 
      glGetUniformLocation(
         self.program, 
         "u_mvpMatrix");
   uniforms[TEBillboardParticleSamplers2D] = 
      glGetUniformLocation(
         self.program, 
         "u_units");
}


#pragma mark -  Render Support

/////////////////////////////////////////////////////////////////
//
- (void)prepareOpenGL
{
   [self loadShadersWithName:@"UtilityBillboardParticleShader"];
}


/////////////////////////////////////////////////////////////////
//
- (void)updateUniformValues
{
   // Pre-calculate the mvpMatrix and normal matrix
   GLKMatrix4 modelViewProjectionMatrix = 
      GLKMatrix4Multiply(
         self.projectionMatrix, 
         self.modelviewMatrix);
         
   // Standard matrices
   glUniformMatrix4fv(uniforms[TEBillboardParticleMVPMatrix], 1, 0, 
      modelViewProjectionMatrix.m);
      
   // Texture samplers
   const GLint   samplerIDs[MAX_TEXTURES] = {0};
   glUniform1iv(uniforms[TEBillboardParticleSamplers2D], 
      MAX_TEXTURES, 
      samplerIDs); 
}


/////////////////////////////////////////////////////////////////
//  
- (void)prepareToDraw;
{
   [super prepareToDraw];

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

@end
