//
//  UtilityModelEffect.m
//  
//

#import "UtilityModelEffect.h"

/////////////////////////////////////////////////////////////////
// TEXTURE
/////////////////////////////////////////////////////////////////
#define MAX_TEXTURES    1
#define MAX_TEX_COORDS  1

/////////////////////////////////////////////////////////////////
// GLSL program uniform indices.
enum
{
   TEModelMVPMatrix,
   TEModelNormalMatrix,
   TEModelSamplers2D,
   TEModelGlobalAmbient,
   TEModelDiffuseLightDirection,
   TEModelDiffuseLightColor,
   TEModelNumUniforms
};


@interface UtilityModelEffect ()
{
   GLint uniforms[TEModelNumUniforms];
}

@end


@implementation UtilityModelEffect

@synthesize projectionMatrix = projectionMatrix_;
@synthesize modelviewMatrix = modelviewMatrix_;
@synthesize texture2D = texture2D_;
@synthesize globalAmbientLightColor = globalAmbientLightColor_;
@synthesize diffuseLightDirection = diffuseLightDirection_;
@synthesize diffuseLightColor = diffuseLightColor_;


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
      UtilityVertexAttribNormal, 
      "a_normal");
   glBindAttribLocation(
      self.program, 
      UtilityVertexAttribTexCoord0, 
      "a_texCoords0");
}


/////////////////////////////////////////////////////////////////
// 
- (void)configureUniformLocations;
{
   uniforms[TEModelMVPMatrix] = glGetUniformLocation(
      self.program, 
      "u_mvpMatrix");
   uniforms[TEModelNormalMatrix] = glGetUniformLocation(
      self.program, 
      "u_normalMatrix");
   uniforms[TEModelSamplers2D] = glGetUniformLocation(
      self.program, 
      "u_units");
   uniforms[TEModelGlobalAmbient] = glGetUniformLocation(
      self.program, 
      "u_globalAmbient");
   uniforms[TEModelDiffuseLightDirection] = glGetUniformLocation(
      self.program, 
      "u_diffuseLightDirection");
   uniforms[TEModelDiffuseLightColor] = glGetUniformLocation(
      self.program, 
      "u_diffuseLightColor");
      
}


#pragma mark -  Render Support

/////////////////////////////////////////////////////////////////
//
- (void)prepareOpenGL
{
   [self loadShadersWithName:@"UtilityModelShader"];
}


/////////////////////////////////////////////////////////////////
// This method exists as a minor optimization to update the 
// light colors matrixwithout updating any other uniform values 
// used by the Shading Language program.
- (void)prepareLightColors;
{
   glUniform4fv(uniforms[TEModelGlobalAmbient], 1, 
      self.globalAmbientLightColor.v);
   glUniform4fv(uniforms[TEModelDiffuseLightColor], 1, 
      self.diffuseLightColor.v);
}


/////////////////////////////////////////////////////////////////
// This method exists as a minor optimization to update the 
// modelview matrixwithout updating any other uniform values 
// used by the Shading Language program.
- (void)prepareModelviewWithoutNormal;
{
   // Pre-calculate the mvpMatrix and normal matrix
   GLKMatrix4 modelViewProjectionMatrix = 
      GLKMatrix4Multiply(
         self.projectionMatrix, 
         self.modelviewMatrix);
         
   glUniformMatrix4fv(uniforms[TEModelMVPMatrix], 1, 0, 
      modelViewProjectionMatrix.m);
}


/////////////////////////////////////////////////////////////////
// This method exists as a minor optimization to update the 
// modelview matrix and normal matrix without updating any other
// uniform values used by the Shading Language program.
- (void)prepareModelview
{
   // Pre-calculate the mvpMatrix and normal matrix
   GLKMatrix4 modelViewProjectionMatrix = 
      GLKMatrix4Multiply(
         self.projectionMatrix, 
         self.modelviewMatrix);
         
   glUniformMatrix4fv(uniforms[TEModelMVPMatrix], 1, 0, 
      modelViewProjectionMatrix.m);

   GLKMatrix3 normalMatrix = 
      GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(
         self.modelviewMatrix, NULL));
   
   glUniformMatrix3fv(uniforms[TEModelNormalMatrix], 1, 
      GL_FALSE, normalMatrix.m);
}


/////////////////////////////////////////////////////////////////
//
- (void)updateUniformValues
{
   [self prepareModelview];
      
   // Texture samplers
   const GLint   samplerIDs[MAX_TEXTURES] = {0};
   glUniform1iv(uniforms[TEModelSamplers2D], MAX_TEXTURES, 
      samplerIDs); 

   // Lighting
   glUniform3fv(uniforms[TEModelDiffuseLightDirection], 1, 
      self.diffuseLightDirection.v);
   [self prepareLightColors];   
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
