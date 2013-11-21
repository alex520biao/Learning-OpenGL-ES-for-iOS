//
//  TEModelEffect.m
//  TerrainEditor
//

#import "TEModelEffect.h"

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
   TEModelGlobalAmbientColor,
   TEModelDiffuseLightDirection,
   TEModelNumUniforms
};


@interface TEModelEffect ()
{
   GLint uniforms[TEModelNumUniforms];
}

@property (assign, nonatomic, readwrite) 
   UtilityVector3 normalEyeDiffuseLightDirection;

@end


@implementation TEModelEffect

@synthesize projectionMatrix;
@synthesize modelviewMatrix;
@synthesize globalAmbientLightColor;
@synthesize diffuseLightDirection;
@synthesize texture2D;

@synthesize normalEyeDiffuseLightDirection;

#pragma mark -  Lifecycle

/////////////////////////////////////////////////////////////////
//  
- (id)init;
{
   if(nil != (self = [super init]))
   {
      self.projectionMatrix = UtilityMatrix4Identity;
      self.modelviewMatrix = UtilityMatrix4Identity;
      self.diffuseLightDirection = UtilityVector3Make(
         1.0f, 1.0f, 1.0f);
      self.globalAmbientLightColor = UtilityVector4Make(
         0.4f, 0.4f, 0.4f, 1.0f);
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//  
- (void)dealloc
{
   [super dealloc];
}


#pragma mark -  Properties with side effects

/////////////////////////////////////////////////////////////////
//  
- (void)setDiffuseLightDirection:(UtilityVector3)aVector
{
   diffuseLightDirection = aVector;
   
   // Store the light direction in Eye coordinates and normalize
   normalEyeDiffuseLightDirection = UtilityVector3Normalize(
      UtilityMatrix4MultiplyVector3(
         self.modelviewMatrix, 
         diffuseLightDirection));
}


#pragma mark -  OpenGL ES 2 shader compilation

/////////////////////////////////////////////////////////////////
// 
- (void)bindAttribLocations;
{
   glBindAttribLocation(
      self.program, 
      TEModelPositionAttrib, 
      "a_position");
   glBindAttribLocation(
      self.program, 
      TEModelNormalAttrib, 
      "a_normal");
   glBindAttribLocation(
      self.program, 
      TEModelTexCoords0Attrib, 
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
   uniforms[TEModelDiffuseLightDirection] = glGetUniformLocation(
      self.program, 
      "u_normalEyeDiffuseLightDirection");
   uniforms[TEModelGlobalAmbientColor] = glGetUniformLocation(
      self.program, 
      "u_globalAmbientColor");
   uniforms[TEModelSamplers2D] = glGetUniformLocation(
      self.program, 
      "u_units");
}


#pragma mark -  Render Support

/////////////////////////////////////////////////////////////////
//
- (void)prepareOpenGL
{
   [self loadShadersWithName:@"ModelShader"];
}


/////////////////////////////////////////////////////////////////
//
- (void)updateUniformValues
{
   // Pre-calculate the mvpMatrix and normal matrix
   UtilityMatrix4 modelViewProjectionMatrix = 
      UtilityMatrix4Multiply(
         self.projectionMatrix, 
         self.modelviewMatrix);

   BOOL isInvertible;
   UtilityMatrix3 normalEyeMatrix = UtilityMatrix4GetMatrix3(
      UtilityMatrix4Transpose(UtilityMatrix4Invert(
         self.modelviewMatrix, &isInvertible)));
   
   if(!isInvertible)
   {
      normalEyeMatrix = UtilityMatrix4GetMatrix3(
         UtilityMatrix4Transpose(self.modelviewMatrix));
   }
   
   // Standard matrices
   glUniformMatrix4fv(uniforms[TEModelMVPMatrix], 1, 0, 
      modelViewProjectionMatrix.m);
   glUniformMatrix3fv(uniforms[TEModelNormalMatrix], 1, 0, 
      normalEyeMatrix.m);
      
   // Ambient light color
   glUniform4fv(uniforms[TEModelGlobalAmbientColor], 1, 
      self.globalAmbientLightColor.v);
      
   // Diffuse light direction
   glUniform3fv(uniforms[TEModelDiffuseLightDirection], 1, 
      self.normalEyeDiffuseLightDirection.v);
      
   // Texture samplers
   const GLint   samplerIDs[MAX_TEXTURES] = {0};
   glUniform1iv(uniforms[TEModelSamplers2D], MAX_TEXTURES, 
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
