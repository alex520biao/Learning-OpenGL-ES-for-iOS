//
//  COLLADARootNode.m
//  COLLADAViewer
//

#import "COLLADARootNode.h"
#import "CVMesh.h"
#import "UtilityTextureLoader.h"


@interface COLLADARootNode ()
{
   UtilityTextureInfo *textureInfo;
   CVMesh *consolidatedMesh;
}

@property (nonatomic, readwrite, retain) UtilityTextureInfo 
   *textureInfo;

@end


@implementation COLLADARootNode

@synthesize path;
@synthesize textureImagePath;
@synthesize consolidatedMesh;


/////////////////////////////////////////////////////////////////
//
- (id)init;
{
   if(nil != (self=[super init]))
   {
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//
- (void)dealloc
{
   [textureInfo release];
   textureInfo = nil;
   [consolidatedMesh release];
   consolidatedMesh = nil;
   
   [super dealloc];
}


/////////////////////////////////////////////////////////////////
//
- (UtilityTextureInfo *)textureInfo
{
   if(nil == textureInfo)
   {
      if(nil != self.textureImagePath)
      {
         NSString *imagePath = [self.path 
            stringByAppendingPathComponent:self.textureImagePath];
         
         NSBitmapImageRep *bitmap = [NSBitmapImageRep 
            imageRepWithContentsOfFile:imagePath];
         
         if(nil == bitmap)
         {
            NSLog(@"Failed to load texture image at <%@>",
                  imagePath);
            glDisable(GL_TEXTURE_2D);
         }
         else
         {
            NSError *error = nil;
            self.textureInfo = [UtilityTextureLoader 
               textureWithCGImage:[bitmap CGImage]                                                      
               options:nil 
               error:&error];
            if(nil == textureInfo)
            {
               NSLog(@"%@", error);
            }
         }      
      }
   }
   
   return textureInfo;
}


/////////////////////////////////////////////////////////////////
//
- (void)setTextureInfo:(UtilityTextureInfo *)info
{
   textureInfo = info;
}


/////////////////////////////////////////////////////////////////
//
- (CVMesh *)consolidatedMesh
{
   if(nil == consolidatedMesh)
   {
      consolidatedMesh = 
         [[CVMesh alloc] init];
         
      [self appendMeshesToMesh:self.consolidatedMesh
         cumulativeTransforms:UtilityMatrix4Identity];
   }
   
   return consolidatedMesh;
}


/////////////////////////////////////////////////////////////////
//
- (void)drawConsolidatedMesh;
{
   glBindTexture (GL_TEXTURE_2D, 0); 
   glDisable(GL_TEXTURE_2D);
   
   if(nil != self.textureImagePath)
   {
      if(nil == self.textureInfo)
      {
         NSString *imagePath = [self.path 
            stringByAppendingPathComponent:self.textureImagePath];
         
         NSBitmapImageRep *bitmap = [NSBitmapImageRep 
            imageRepWithContentsOfFile:imagePath];
         
         if(nil == bitmap)
         {
            NSLog(@"Failed to load texture image at <%@>",
                  imagePath);
            glDisable(GL_TEXTURE_2D);
         }
         else
         {
            NSError *error = nil;
            self.textureInfo = [UtilityTextureLoader 
               textureWithCGImage:[bitmap CGImage]                                                      
               options:nil 
               error:&error];
            if(nil == self.textureInfo)
            {
               NSLog(@"%@", error);
            }
            else
            {
               glBindTexture (GL_TEXTURE_2D, 
                  self.textureInfo.name); 
               glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, 
                  GL_MODULATE);
               glEnable(GL_TEXTURE_2D);
            }
         }      
      }
      else
      {
         glBindTexture(GL_TEXTURE_2D, self.textureInfo.name); 
         glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
         glEnable(GL_TEXTURE_2D);
      }
   }
   
   [self.consolidatedMesh prepareToDraw];
   [self.consolidatedMesh drawAllCommands];
}   


/////////////////////////////////////////////////////////////////
//
- (void)drawNormalsConsolidatedMesh;
{
   [self.consolidatedMesh drawNormalsAllCommandsLength:0.1f];
}


/////////////////////////////////////////////////////////////////
//
- (void)draw;
{
   glBindTexture (GL_TEXTURE_2D, 0); 
   glDisable(GL_TEXTURE_2D);
   
   if(nil != self.textureImagePath)
   {
      if(nil == self.textureInfo)
      {
         NSString *imagePath = [self.path 
            stringByAppendingPathComponent:self.textureImagePath];
         
         NSBitmapImageRep *bitmap = [NSBitmapImageRep 
            imageRepWithContentsOfFile:imagePath];
         
         if(nil == bitmap)
         {
            NSLog(@"Failed to load texture image at <%@>",
                  imagePath);
            glDisable(GL_TEXTURE_2D);
         }
         else
         {
            NSError *error = nil;
            self.textureInfo = [UtilityTextureLoader 
               textureWithCGImage:[bitmap CGImage]                                                      
               options:nil 
               error:&error];
            if(nil == self.textureInfo)
            {
               NSLog(@"%@", error);
            }
            else
            {
               glBindTexture (GL_TEXTURE_2D, 
                  self.textureInfo.name); 
               glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, 
                  GL_MODULATE);
               glEnable(GL_TEXTURE_2D);
            }
         }      
      }
      else
      {
         glBindTexture(GL_TEXTURE_2D, self.textureInfo.name); 
         glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
         glEnable(GL_TEXTURE_2D);
      }
   }
   
   [super draw];
}   


/////////////////////////////////////////////////////////////////
//
- (void)drawNormals
{
   glDisable(GL_TEXTURE_2D);
   [super drawNormals];
}


/////////////////////////////////////////////////////////////////
//
-(NSUInteger)numberOfElements;
{
   NSUInteger result = 0;
   
   if(nil != self.consolidatedMesh)
   {
      result = self.consolidatedMesh.numberOfIndices;
   }
   
   return result;
}

@end
