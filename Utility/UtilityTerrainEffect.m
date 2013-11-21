//
//  UtilityTerrainEffect.m
//  
//

#import <GLKit/GLKit.h>
#import "UtilityTerrainEffect.h"
#import "TETerrain+viewAdditions.h"
#import "TETerrainTile.h"
#import "UtilityTextureInfo+viewAdditions.h"


/////////////////////////////////////////////////////////////////
// TEXTURE
/////////////////////////////////////////////////////////////////
#define MAX_TEXTURES    5
#define MAX_TEX_COORDS  5

/////////////////////////////////////////////////////////////////
// GLSL program uniform indices.
enum
{
   TETerrainMVPMatrix,
   TETerrainTexureMatrices,
   TETerrainToolTexureMatrix,
   TETerrainSamplers2D,
   TETerrainGlobalAmbientColor,
   TETerrainNumUniforms
};


@interface UtilityTerrainEffect ()
{
   GLint uniforms[TETerrainNumUniforms];
   GLKMatrix3 textureMatrices[MAX_TEXTURES];
}

@property(assign, nonatomic, readwrite) GLKMatrix4 
   toolTextureMatrix;
@property(assign, nonatomic, readwrite) GLfloat toolAngle;
@property(assign, nonatomic, readwrite) GLfloat metersPerUnit;

@end


@implementation UtilityTerrainEffect

@synthesize globalAmbientLightColor = globalAmbientLightColor_;
@synthesize projectionMatrix = projectionMatrix_;
@synthesize modelviewMatrix = modelviewMatrix_;
@synthesize textureMatrix0 = textureMatrix0_;
@synthesize textureMatrix1 = textureMatrix1_;
@synthesize textureMatrix2 = textureMatrix2_;
@synthesize textureMatrix3 = textureMatrix3_;
@synthesize lightAndWeightsTextureInfo = 
   lightAndWeightsTextureInfo_;
@synthesize detailTextureInfo0 = detailTextureInfo0_;
@synthesize detailTextureInfo1 = detailTextureInfo1_;
@synthesize detailTextureInfo2 = detailTextureInfo2_;
@synthesize detailTextureInfo3 = detailTextureInfo3_;

@synthesize toolTextureMatrix = toolTextureMatrix_;
@synthesize toolAngle = toolAngle_;
@synthesize metersPerUnit = metersPerUnit_;

#pragma mark -  Lifecycle

/////////////////////////////////////////////////////////////////
//  
- (id)init;
{
   NSAssert(0, @"Invalid initializer");
   self = nil;
   
   return self;
}


/////////////////////////////////////////////////////////////////
// Designated Initializer 
- (id)initWithTerrain:(TETerrain *)aTerrain;
{
   NSParameterAssert(nil != aTerrain);
   
   if(nil != (self = [super init]))
   {
      const GLfloat metersPerUnit = self.metersPerUnit;
      const GLfloat widthMeters = aTerrain.widthMeters;
      const GLfloat lengthMeters = aTerrain.lengthMeters;
      self.metersPerUnit = aTerrain.metersPerUnit;
      
      // Setup default texture matrices
      textureMatrices[0] = GLKMatrix3MakeScale(
         1.0f / widthMeters, 
         1.0f, 
         1.0f / lengthMeters);
      textureMatrices[1] = GLKMatrix3MakeScale(
         1.0f / metersPerUnit, 
         1.0f / metersPerUnit, 
         1.0f / metersPerUnit);
      textureMatrices[2] = GLKMatrix3MakeScale(
         1.0f / metersPerUnit, 
         1.0f / metersPerUnit, 
         1.0f / metersPerUnit);
      textureMatrices[3] = GLKMatrix3MakeScale(
         1.0f / metersPerUnit, 
         1.0f / metersPerUnit, 
         1.0f / metersPerUnit);
      textureMatrices[4] = GLKMatrix3MakeScale(
         1.0f / metersPerUnit, 
         1.0f / metersPerUnit, 
         1.0f / metersPerUnit);      
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
      TETerrainPositionAttrib, 
      "a_position");
}


/////////////////////////////////////////////////////////////////
// 
- (void)configureUniformLocations;
{
   uniforms[TETerrainMVPMatrix] = glGetUniformLocation(
      self.program, 
      "u_mvpMatrix");
   uniforms[TETerrainTexureMatrices] = glGetUniformLocation(
      self.program, 
      "u_texMatrices");
   uniforms[TETerrainToolTexureMatrix] = glGetUniformLocation(
      self.program, 
      "u_toolTextureMatrix");
   uniforms[TETerrainGlobalAmbientColor] = glGetUniformLocation(
      self.program, 
      "u_globalAmbientColor");
   uniforms[TETerrainSamplers2D] = glGetUniformLocation(
      self.program, 
      "u_units");
}


#pragma mark -  Render Support

/////////////////////////////////////////////////////////////////
//
- (void)prepareOpenGL
{
   [self loadShadersWithName:@"UtilityTerrainShader"];

#ifdef DEBUG
   int maxVertexTextureImageUnits;
   glGetIntegerv(GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS, &maxVertexTextureImageUnits);
   int maxCombinedTextureImageUnits;
   glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &maxCombinedTextureImageUnits);
   
   NSLog(@"Available texture units: vertex:%d, total:%d",
      maxVertexTextureImageUnits,
      maxCombinedTextureImageUnits); 
#endif
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
   glUniformMatrix4fv(uniforms[TETerrainMVPMatrix], 1, 0, 
      modelViewProjectionMatrix.m);
   
   //Texture matrices
   glUniformMatrix3fv(uniforms[TETerrainTexureMatrices], 
      MAX_TEXTURES, 0, textureMatrices[0].m);
   glUniformMatrix4fv(uniforms[TETerrainToolTexureMatrix], 1, 0, 
      self.toolTextureMatrix.m);

   // Ambient light color
   glUniform4fv(uniforms[TETerrainGlobalAmbientColor], 1, 
      self.globalAmbientLightColor.v);
      
   // Texture samplers
   const GLint   samplerIDs[MAX_TEXTURES] = {0, 1, 2, 3, 4};
   glUniform1iv(uniforms[TETerrainSamplers2D], MAX_TEXTURES, 
      samplerIDs); 
}


/////////////////////////////////////////////////////////////////
//  
- (void)prepareToDraw;
{
   [super prepareToDraw];

   // bind textures
   glActiveTexture(GL_TEXTURE0);
   glBindTexture(GL_TEXTURE_2D, 
      self.lightAndWeightsTextureInfo.name);
   glActiveTexture(GL_TEXTURE1);
   glBindTexture(GL_TEXTURE_2D, 
      self.detailTextureInfo0.name);
   glActiveTexture(GL_TEXTURE2);
   glBindTexture(GL_TEXTURE_2D, 
      self.detailTextureInfo1.name);      
   glActiveTexture(GL_TEXTURE3);
   glBindTexture(GL_TEXTURE_2D, 
      self.detailTextureInfo2.name);      
   glActiveTexture(GL_TEXTURE4);
   glBindTexture(GL_TEXTURE_2D, 
      self.detailTextureInfo3.name);      
}


#pragma mark -  Property Support

/////////////////////////////////////////////////////////////////
// 
- (GLKMatrix3)textureMatrix0
{
   return textureMatrices[1];
}


/////////////////////////////////////////////////////////////////
// 
- (void)setTextureMatrix0:(GLKMatrix3)aMatrix
{
   textureMatrices[1] = aMatrix;
}


/////////////////////////////////////////////////////////////////
// 
- (GLKMatrix3)textureMatrix1
{
   return textureMatrices[2];
}


/////////////////////////////////////////////////////////////////
// 
- (void)setTextureMatrix1:(GLKMatrix3)aMatrix
{
   textureMatrices[2] = aMatrix;
}


/////////////////////////////////////////////////////////////////
// 
- (GLKMatrix3)textureMatrix2
{
   return textureMatrices[3];
}


/////////////////////////////////////////////////////////////////
// 
- (void)setTextureMatrix2:(GLKMatrix3)aMatrix
{
   textureMatrices[3] = aMatrix;
}


/////////////////////////////////////////////////////////////////
// 
- (GLKMatrix3)textureMatrix3
{
   return textureMatrices[4];
}


/////////////////////////////////////////////////////////////////
// 
- (void)setTextureMatrix3:(GLKMatrix3)aMatrix
{
   textureMatrices[4] = aMatrix;
}

@end
