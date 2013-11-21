//
//  UtilityTextureInfo+viewAdditions.m
//  
//

#import "UtilityTextureInfo+viewAdditions.h"


@implementation UtilityTextureInfo (viewAdditions)

- (GLuint)name;
{
   if(nil == self.userInfo)
   {
      self.userInfo = [GLKTextureInfo 
         textureInfoFromUtilityPlistRepresentation:self.plist];
      [self discardPlist];
   }
   NSAssert([self.userInfo isKindOfClass:[GLKTextureInfo class]],
      @"Invalid userInfo");
      
   return [(GLKTextureInfo *)self.userInfo name];
}


- (GLenum)target;
{
   if(nil == self.userInfo)
   {
      self.userInfo = [GLKTextureInfo 
         textureInfoFromUtilityPlistRepresentation:self.plist];
      [self discardPlist];
   }
   NSAssert([self.userInfo isKindOfClass:[GLKTextureInfo class]],
      @"Invalid userInfo");
      
   return [(GLKTextureInfo *)self.userInfo target];
}

@end


@implementation GLKTextureInfo (utilityAdditions)

/////////////////////////////////////////////////////////////////
// Returns a GLKTextureInfo instance initialized based upon
// information provided in aDictionary.
+ (GLKTextureInfo *)textureInfoFromUtilityPlistRepresentation:
   (NSDictionary *)aDictionary
{
   GLKTextureInfo *result = nil;
   
   const size_t imageWidth = (size_t)[[aDictionary 
      objectForKey:@"width"] unsignedIntegerValue];
   const size_t imageHeight = (size_t)[[aDictionary 
      objectForKey:@"height"] unsignedIntegerValue];
   
   // The imageData property is expected to be a Tiff image
   UIImage *image = [UIImage imageWithData:
      [aDictionary objectForKey:@"imageData"]];
   
   if(nil != image && 0 != imageWidth && 0 != imageHeight)
   {  // Create GLKTextureInfo corresponding to image.
      NSError *error;
      result = 
         [GLKTextureLoader textureWithCGImage:[image CGImage] 
            options:[NSDictionary dictionaryWithObjectsAndKeys:
               [NSNumber numberWithBool:YES], 
               GLKTextureLoaderGenerateMipmaps, 
               [NSNumber numberWithBool:NO], 
               GLKTextureLoaderOriginBottomLeft, 
               [NSNumber numberWithBool:NO], 
               GLKTextureLoaderApplyPremultiplication, 
               nil] 
            error:&error];
         
      if(nil == result)
      {
         NSLog(@"%@", error);
      }
      else
      {
         glTexParameteri(GL_TEXTURE_2D, 
            GL_TEXTURE_MAG_FILTER, 
            GL_LINEAR);
         glTexParameteri(GL_TEXTURE_2D, 
            GL_TEXTURE_MIN_FILTER, 
            GL_NEAREST_MIPMAP_LINEAR);
         glTexParameteri(
            GL_TEXTURE_2D, 
            GL_TEXTURE_WRAP_S, 
            GL_REPEAT);
         glTexParameteri(
            GL_TEXTURE_2D, 
            GL_TEXTURE_WRAP_T, 
            GL_REPEAT);
      }
   }
      
   return result;
}

@end
