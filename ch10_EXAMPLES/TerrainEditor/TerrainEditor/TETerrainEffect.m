//
//  TETerrainEffect.m
//  TerrainViewer
//

#import "TETerrainEffect.h"
#import "TETerrain+modelAdditions.h"
#import "TETerrainTile.h"
#import "UtilityMatrix.h"


/////////////////////////////////////////////////////////////////
// TEXTURE
/////////////////////////////////////////////////////////////////
#define MAX_TEXTURES    6
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


@interface TETerrainEffect ()
{
   GLint uniforms[TETerrainNumUniforms];
   UtilityMatrix3 textureMatrices[MAX_TEXTURES];
}

@property(assign, nonatomic, readwrite) UtilityMatrix4 toolTextureMatrix;
@property(assign, nonatomic, readwrite) GLfloat toolAngle;
@property(assign, nonatomic, readwrite) GLfloat metersPerUnit;

@end


@implementation TETerrainEffect

@synthesize globalAmbientLightColor;
@synthesize projectionMatrix;
@synthesize modelviewMatrix;
@synthesize textureMatrix0;
@synthesize textureMatrix1;
@synthesize textureMatrix2;
@synthesize textureMatrix3;
@synthesize toolLocation;
@synthesize toolTextureRadius;
@synthesize lightAndWeightsTextureInfo;
@synthesize detailTextureInfo0;
@synthesize detailTextureInfo1;
@synthesize detailTextureInfo2;
@synthesize detailTextureInfo3;
@synthesize toolTextureInfo;

@synthesize toolTextureMatrix;
@synthesize toolAngle;
@synthesize metersPerUnit;

#pragma mark -  Lifecycle

/////////////////////////////////////////////////////////////////
//  
- (id)init;
{
   NSAssert(0, @"Invalid initializer");
   [self release];
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
      //self.terrain = aTerrain;
      
      const GLfloat widthMeters = aTerrain.widthMeters;
      const GLfloat lengthMeters = aTerrain.lengthMeters;
      self.metersPerUnit = [aTerrain.metersPerUnit floatValue];
      
      // Setup default texture matrices
      textureMatrices[0] = UtilityMatrix3MakeScale(
         1.0f / widthMeters, 
         1.0f, 
         1.0f / lengthMeters);
      textureMatrices[1] = UtilityMatrix3MakeScale(
         1.0f / metersPerUnit, 
         1.0f / metersPerUnit, 
         1.0f / metersPerUnit);
      textureMatrices[2] = UtilityMatrix3MakeScale(
         1.0f / metersPerUnit, 
         1.0f / metersPerUnit, 
         1.0f / metersPerUnit);
      textureMatrices[3] = UtilityMatrix3MakeScale(
         1.0f / metersPerUnit, 
         1.0f / metersPerUnit, 
         1.0f / metersPerUnit);
      textureMatrices[4] = UtilityMatrix3MakeScale(
         1.0f / metersPerUnit, 1.0f / metersPerUnit, 1.0f / metersPerUnit);
      
      // Tool texture matrix
      toolTextureMatrix =
         UtilityMatrix4MakeTranslation(-0.5f, 0.0f, -0.5f);
         
      self.toolTextureRadius = 3.5f;      
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//  
- (void)dealloc
{
   [super dealloc];
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
   [self loadShadersWithName:@"TerrainShader"];

   /*****
   int maxVertexTextureImageUnits;
   glGetIntegerv(GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS, &maxVertexTextureImageUnits);
   int maxCombinedTextureImageUnits;
   glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &maxCombinedTextureImageUnits);
   
   NSLog(@"Available texture units: %d, %d", maxVertexTextureImageUnits,
      maxCombinedTextureImageUnits); 
   *****/
   
   glBindTexture(GL_TEXTURE_2D, [self.toolTextureInfo name]);
   glTexParameteri(
      GL_TEXTURE_2D, 
      GL_TEXTURE_WRAP_S, 
      GL_CLAMP);
   glTexParameteri(
      GL_TEXTURE_2D, 
      GL_TEXTURE_WRAP_T, 
      GL_CLAMP);
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
   glUniformMatrix4fv(uniforms[TETerrainMVPMatrix], 1, 0, 
      modelViewProjectionMatrix.m);
   
   //Texture matrices
   glUniformMatrix3fv(uniforms[TETerrainTexureMatrices], MAX_TEXTURES, 0, 
      textureMatrices[0].m);
   glUniformMatrix4fv(uniforms[TETerrainToolTexureMatrix], 1, 0, 
      toolTextureMatrix.m);

   // Ambient light color
   glUniform4fv(uniforms[TETerrainGlobalAmbientColor], 1, 
      self.globalAmbientLightColor.v);
      
   // Texture samplers
   const GLint   samplerIDs[MAX_TEXTURES] = {0, 1, 2, 3, 4, 5};
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
   glActiveTexture(GL_TEXTURE5);
   glBindTexture(GL_TEXTURE_2D, 
      self.toolTextureInfo.name); 
}


#pragma mark -  Property Support

/////////////////////////////////////////////////////////////////
//  
- (void)updateTool;
{
   const GLfloat constMetersPerUnit = self.metersPerUnit;
   self.toolAngle += 0.01;

   toolTextureMatrix = UtilityMatrix4Identity;
   toolTextureMatrix = UtilityMatrix4Translate(toolTextureMatrix,
      0.5f, 0.0f, 0.5f);   
   toolTextureMatrix = UtilityMatrix4Rotate(toolTextureMatrix,
      toolAngle,
      0.0f, 1.0f, 0.0f);   
   toolTextureMatrix = UtilityMatrix4Scale(toolTextureMatrix,
      (1.0f / toolTextureRadius) / constMetersPerUnit, 
      1.0f, 
      (1.0f / toolTextureRadius) / constMetersPerUnit);   
   toolTextureMatrix = UtilityMatrix4Translate(toolTextureMatrix,
      -0.5f, 0.0f, -0.5f);
   toolTextureMatrix =
      UtilityMatrix4Translate(toolTextureMatrix,
      -toolLocation.x * constMetersPerUnit, 
      0.0f, 
      -toolLocation.y * constMetersPerUnit);
}


/////////////////////////////////////////////////////////////////
// 
- (UtilityMatrix3)textureMatrix0
{
   return textureMatrices[1];
}


/////////////////////////////////////////////////////////////////
// 
- (void)setTextureMatrix0:(UtilityMatrix3)aMatrix
{
   textureMatrices[1] = aMatrix;
}


/////////////////////////////////////////////////////////////////
// 
- (UtilityMatrix3)textureMatrix1
{
   return textureMatrices[2];
}


/////////////////////////////////////////////////////////////////
// 
- (void)setTextureMatrix1:(UtilityMatrix3)aMatrix
{
   textureMatrices[2] = aMatrix;
}


/////////////////////////////////////////////////////////////////
// 
- (UtilityMatrix3)textureMatrix2
{
   return textureMatrices[3];
}


/////////////////////////////////////////////////////////////////
// 
- (void)setTextureMatrix2:(UtilityMatrix3)aMatrix
{
   textureMatrices[3] = aMatrix;
}


/////////////////////////////////////////////////////////////////
// 
- (UtilityMatrix3)textureMatrix3
{
   return textureMatrices[4];
}


/////////////////////////////////////////////////////////////////
// 
- (void)setTextureMatrix3:(UtilityMatrix3)aMatrix
{
   textureMatrices[4] = aMatrix;
}

@end
