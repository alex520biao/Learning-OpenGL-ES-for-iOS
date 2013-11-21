//
//  UtilityTextureLoader.m
//  
//

#import "UtilityTextureLoader.h"

/////////////////////////////////////////////////////////////////
// This data type is used specify power of 2 values.  OpenGL ES 
// best supports texture images that have power of 2 dimensions.
typedef enum
{
   Utility1 = 1,
   Utility2 = 2,
   Utility4 = 4,
   Utility8 = 8,
   Utility16 = 16,
   Utility32 = 32,
   Utility64 = 64,
   Utility128 = 128,
   Utility256 = 256,
   Utility512 = 512,
   Utility1024 = 1024,
   Utility2048 = 2048,
} 
UtilityPowerOf2;


/////////////////////////////////////////////////////////////////
// Forward declaration of function
static UtilityPowerOf2 UtilityCalculatePowerOf2ForDimension(
   size_t dimension);

/////////////////////////////////////////////////////////////////
// Forward declaration of functions
static NSData *UtilityDataWithResizedCGImage(
   CGImageRef cgImage,
   UtilityPowerOf2 *widthPtr,
   UtilityPowerOf2 *heightPtr,
   BOOL shouldFlip);
static NSData *UtilityDataWithFlippedImageData(
   NSData *originalData,
   UtilityPowerOf2 width,
   UtilityPowerOf2 height);
static NSData *UtilityDataWithImageData(
   NSData *originalData,
   UtilityPowerOf2 width,
   UtilityPowerOf2 height);

                              
@interface UtilityTextureInfo ()
{
@private
   GLuint name;
   GLenum target;
   UtilityPowerOf2 imageWidth;
   UtilityPowerOf2 imageHeight;
}
   
@property (nonatomic, readwrite, strong) NSData *imageData;

- (id)initWithData:(NSData *)someData
   width:(UtilityPowerOf2)aWidth
   height:(UtilityPowerOf2)aHeight;

@end


@implementation UtilityTextureInfo

@synthesize name;
@synthesize target;
@synthesize imageData;

- (size_t)width
{
   return imageWidth;
}


- (size_t)height
{
   return imageHeight;
}


/////////////////////////////////////////////////////////////////
// This method is the designated initializer.
- (id)initWithData:(NSData *)someData
   width:(UtilityPowerOf2)aWidth
   height:(UtilityPowerOf2)aHeight
{
    if (nil != (self = [super init])) 
    {
        if(nil == someData || 0 == aWidth || 0 == aHeight)
        {  // Can not initialize with null data or zero dimension
           self = nil;
        }
        else
        {
           name = 0;
           target = GL_TRIANGLES;
           imageWidth = aWidth;
           imageHeight = aHeight;
           imageData = [someData retain];
        }
    }
    
    return self;
}


/////////////////////////////////////////////////////////////////
//
- (id)initWithPlistRepresentation:(NSDictionary *)aDictionary;
{
   size_t width = (size_t)[[aDictionary objectForKey:@"width"] 
            unsignedIntegerValue];
   size_t height = (size_t)[[aDictionary objectForKey:@"height"] 
            unsignedIntegerValue];
   imageWidth = 
      UtilityCalculatePowerOf2ForDimension(width);
   imageHeight = 
      UtilityCalculatePowerOf2ForDimension(height);
      
   // The imageData property is expected to be
   // a Tiff image
   NSData *loadedImageData = [aDictionary objectForKey:@"imageData"];
   NSBitmapImageRep *imageRep = 
      [NSBitmapImageRep imageRepWithData:loadedImageData];
   
   if(nil == imageRep)
   {
      if(nil != loadedImageData)
      {
         const size_t requiredRawSize = (imageWidth * imageHeight * 4);
         
         if([loadedImageData length] != requiredRawSize)
         {
            loadedImageData = nil;
         }
         else
         { // As a fallback, assume this is raw image data in RGBA format
            loadedImageData = UtilityDataWithImageData(
               loadedImageData,
               imageWidth,
               imageHeight);
         }
      }
   }
   else
   {
      loadedImageData = UtilityDataWithResizedCGImage(
          [imageRep CGImage],
          &imageWidth,
          &imageHeight,
          NO);
   }

   if(nil == loadedImageData || 0 == imageWidth || 0 == imageHeight)
   {
      self = nil;
   }
   else
   {
      self = [self initWithData:loadedImageData
            width:imageWidth
            height:imageHeight];
   }
      
   return self;
}


/////////////////////////////////////////////////////////////////
//
- (void)dealloc
{
   if(0 != name)
   {
      NSLog(@"DeleteTexture: %d", name);
      glDeleteTextures(1, &name);
   }
   [imageData release];
   imageData = nil;
   
   [super dealloc];
}


/////////////////////////////////////////////////////////////////
//
- (NSDictionary *)plistRepresentation
{
   return [NSDictionary dictionaryWithObjectsAndKeys:
      [[self image] TIFFRepresentation], 
      @"imageData", 
      [NSNumber numberWithUnsignedInteger:self.width], 
      @"width", 
      [NSNumber numberWithUnsignedInteger:self.height], 
      @"height", 
      nil];
}


/////////////////////////////////////////////////////////////////
//
- (GLuint)name
{
   if(0 == name && nil != self.imageData)
   {
      // Generation, bind, and copy data into a new texture buffer
      GLuint      textureBufferID;
      
      glGenTextures(1, &textureBufferID); 
      glBindTexture(GL_TEXTURE_2D, textureBufferID);
      glTexImage2D(
         GL_TEXTURE_2D, 
         0, 
         GL_RGBA, 
         (GLsizei)self.width,
         (GLsizei)self.height, 
         0, 
         GL_RGBA, 
         GL_UNSIGNED_BYTE, 
         [imageData bytes]);
      
      // Set parameters that control texture sampling for 
      // the bound texture
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
      glGenerateMipmap(GL_TEXTURE_2D);
      
      name = textureBufferID;
      
#ifdef DEBUG
      NSLog(@"CreateTexture: %d", name);
      {  // Report any errors 
         GLenum error = glGetError();
         if(GL_NO_ERROR != error)
         {
            NSLog(@"GL Error: 0x%x", error);
         }
      }
#endif
   }
   
   return name;
}


/////////////////////////////////////////////////////////////////
//
- (void)discardLocalImageData;
{
   self.imageData = nil;
}


/////////////////////////////////////////////////////////////////
//
- (NSImage *)image;
{
   NSImage *result = nil;
   
   NSMutableData *mutableImageData = [[imageData mutableCopy]
      autorelease];
      
   if(nil != mutableImageData)
   {
      CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
      CGContextRef cgContext = CGBitmapContextCreate( 
         [mutableImageData mutableBytes], 
         imageWidth, 
         imageHeight, 
         8, 
         4 * imageWidth, 
         colorSpace, 
         kCGImageAlphaPremultipliedLast);
      CGColorSpaceRelease(colorSpace);
      CGImageRef imageRef = CGBitmapContextCreateImage(
         cgContext);
      result = 
         [[[NSImage alloc] initWithCGImage:imageRef 
         size:NSMakeSize(self.width, self.height)] autorelease];
      CGImageRelease(imageRef);
      CGContextRelease(cgContext);
   }
   
   return result;
}

#pragma mark - NSCoding

/////////////////////////////////////////////////////////////////
//
- (void)encodeWithCoder:(NSCoder *)aCoder;
{
   [aCoder encodeObject:[self plistRepresentation] 
      forKey:@"plist"];
}


/////////////////////////////////////////////////////////////////
//
- (id)initWithCoder:(NSCoder *)aDecoder;
{
   NSDictionary *plist = [aDecoder decodeObjectForKey:@"plist"];
   
   return [self initWithPlistRepresentation:plist];
}


/////////////////////////////////////////////////////////////////
//
- (id)copyWithZone:(NSZone *)zone
{
   UtilityTextureInfo *result = [[UtilityTextureInfo alloc] 
      initWithData:self.imageData
      width:imageWidth
      height:imageHeight];
      
   return result;
}

@end


@implementation UtilityTextureLoader

/////////////////////////////////////////////////////////////////
// This method generates a new OpenGL ES texture buffer and 
// initializes the buffer contents using pixel data from the 
// specified Core Graphics image, cgImage. This method returns an
// immutable UtilityTextureInfo instance initialized with 
// information about the newly generated texture buffer.
//    The generated texture buffer has power of 2 dimensions. The
// provided image data is scaled (re-sampled) by Core Graphics as
// necessary to fit within the generated texture buffer.
+ (UtilityTextureInfo *)textureWithCGImage:(CGImageRef)cgImage
   options:(NSDictionary *)options
   error:(NSError **)outError; 
{
   // Get the bytes to be used when copying data into new texture
   // buffer
   UtilityPowerOf2 width;
   UtilityPowerOf2 height;
   NSData *imageData = UtilityDataWithResizedCGImage(
      cgImage,
      &width,
      &height,
      YES);
   
   /*****
   [[[[[NSBitmapImageRep alloc] initWithCGImage:cgImage] 
      autorelease] TIFFRepresentation]
      writeToFile:[@"~/texture.tiff" stringByExpandingTildeInPath] 
      atomically:YES];
   *****/
   
   // Allocate and initialize the UtilityTextureInfo instance to be
   // returned
   UtilityTextureInfo *result = [[[UtilityTextureInfo alloc] 
      initWithData:imageData
      width:width
      height:height]
      autorelease];
   
   return result;
}
                                 
@end


/////////////////////////////////////////////////////////////////
// 
static NSData *UtilityDataWithFlippedImageData(
   NSData *originalData,
   UtilityPowerOf2 width,
   UtilityPowerOf2 height)
{
   NSCParameterAssert(nil != originalData);   
   NSCAssert(0 < width, @"Invalid image width");
   NSCAssert(0 < height, @"Invalid image width");
   
   // Allocate sufficient storage for RGBA pixel color data with 
   // the power of 2 sizes specified
   NSMutableData    *imageData = [NSMutableData dataWithLength:
      height * width * 4];  // 4 bytes per RGBA pixel
   NSMutableData    *mutableOriginalData = 
      [NSMutableData dataWithData:originalData];

   NSCAssert(nil != imageData, 
      @"Unable to allocate image storage");
   
   // Create a Core Graphics context that draws into the 
   // allocated bytes
   CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
   CGContextRef cgContext = CGBitmapContextCreate( 
      [imageData mutableBytes], width, height, 8, 
      4 * width, colorSpace, 
      kCGImageAlphaPremultipliedLast);
   
   // Create a Core Graphics context that contains the original 
   // image data
   CGContextRef cgOriginalContext = CGBitmapContextCreate( 
      [mutableOriginalData mutableBytes], width, height, 8, 
      4 * width, colorSpace, 
      kCGImageAlphaPremultipliedLast);
   CGColorSpaceRelease(colorSpace);
   
   CGImageRef originalImage = CGBitmapContextCreateImage(
      cgOriginalContext);
      
   // Flip the Core Graphics Y-axis for future drawing
   CGContextTranslateCTM (cgContext, 0, height);
   CGContextScaleCTM (cgContext, 1.0, -1.0);
   
   // Draw the loaded image into the Core Graphics context 
   // resizing as necessary
   CGContextDrawImage(cgContext, CGRectMake(0, 0, width, height),
      originalImage);
   
   /*****
   {  
      CGImageRef debugImageRef = CGBitmapContextCreateImage(
         cgContext);
      NSLog(@"%p", debugImageRef);
      [[[[[NSBitmapImageRep alloc] initWithCGImage:debugImageRef] 
         autorelease] TIFFRepresentation]
         writeToFile:
            [@"~/debug.tiff" stringByExpandingTildeInPath] 
         atomically:YES];
      CGImageRelease(debugImageRef);
   }
   *****/
   
   CGImageRelease(originalImage);
   CGContextRelease(cgContext);
   CGContextRelease(cgOriginalContext);
   
   return imageData;
}


/////////////////////////////////////////////////////////////////
// 
static NSData *UtilityDataWithImageData(
   NSData *originalData,
   UtilityPowerOf2 width,
   UtilityPowerOf2 height)
{
   NSCParameterAssert(nil != originalData);   
   NSCAssert(0 < width, @"Invalid image width");
   NSCAssert(0 < height, @"Invalid image width");
   
   // Allocate sufficient storage for RGBA pixel color data with 
   // the power of 2 sizes specified
   NSMutableData    *imageData = [NSMutableData dataWithLength:
      height * width * 4];  // 4 bytes per RGBA pixel
   NSMutableData    *mutableOriginalData = 
      [NSMutableData dataWithData:originalData];

   NSCAssert(nil != imageData, 
      @"Unable to allocate image storage");
   
   // Create a Core Graphics context that draws into the 
   // allocated bytes
   CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
   CGContextRef cgContext = CGBitmapContextCreate( 
      [imageData mutableBytes], width, height, 8, 
      4 * width, colorSpace, 
      kCGImageAlphaPremultipliedLast);
   
   // Create a Core Graphics context that contains the original 
   // image data
   CGContextRef cgOriginalContext = CGBitmapContextCreate( 
      [mutableOriginalData mutableBytes], width, height, 8, 
      4 * width, colorSpace, 
      kCGImageAlphaPremultipliedLast);
   CGColorSpaceRelease(colorSpace);
   
   CGImageRef originalImage = CGBitmapContextCreateImage(
      cgOriginalContext);
      
   // Draw the loaded image into the Core Graphics context 
   // resizing as necessary
   CGContextDrawImage(cgContext, CGRectMake(0, 0, width, height),
      originalImage);
   
   /*****
   {  
      CGImageRef debugImageRef = CGBitmapContextCreateImage(
         cgContext);
      NSLog(@"%p", debugImageRef);
      [[[[[NSBitmapImageRep alloc] initWithCGImage:debugImageRef] 
         autorelease] TIFFRepresentation]
         writeToFile:
            [@"~/debug.tiff" stringByExpandingTildeInPath] 
         atomically:YES];
      CGImageRelease(debugImageRef);
   }
   *****/
   
   CGImageRelease(originalImage);
   CGContextRelease(cgContext);
   CGContextRelease(cgOriginalContext);
   
   return imageData;
}


/////////////////////////////////////////////////////////////////
// This function returns an NSData object that contains bytes
// loaded from the specified Core Graphics image, cgImage. This
// function also returns (by reference) the power of 2 width and 
// height to be used when initializing an OpenGL ES texture 
// buffer with the bytes in the returned NSData instance. The 
// widthPtr and heightPtr arguments must be valid pointers.
static NSData *UtilityDataWithResizedCGImage(
   CGImageRef cgImage,
   UtilityPowerOf2 *widthPtr,
   UtilityPowerOf2 *heightPtr,
   BOOL shouldFlip)
{
   NSCParameterAssert(NULL != cgImage);
   NSCParameterAssert(NULL != widthPtr);
   NSCParameterAssert(NULL != heightPtr);
   
   size_t originalWidth = CGImageGetWidth(cgImage);
   size_t originalHeight = CGImageGetHeight(cgImage);
   
   NSCAssert(0 < originalWidth, @"Invalid image width");
   NSCAssert(0 < originalHeight, @"Invalid image width");
   
   // Calculate the width and height of the new texture buffer
   // The new texture buffer will have power of 2 dimensions.
   UtilityPowerOf2 width = UtilityCalculatePowerOf2ForDimension(
      (GLsizei)originalWidth);
   UtilityPowerOf2 height = UtilityCalculatePowerOf2ForDimension(
      (GLsizei)originalHeight);
      
   // Allocate sufficient storage for RGBA pixel color data with 
   // the power of 2 sizes specified
   NSMutableData    *imageData = [NSMutableData dataWithLength:
      height * width * 4];  // 4 bytes per RGBA pixel

   NSCAssert(nil != imageData, 
      @"Unable to allocate image storage");
   
   // Create a Core Graphics context that draws into the 
   // allocated bytes
   CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
   CGContextRef cgContext = CGBitmapContextCreate( 
      [imageData mutableBytes], width, height, 8, 
      4 * width, colorSpace, 
      kCGImageAlphaPremultipliedLast);
   CGColorSpaceRelease(colorSpace);
   
   if(shouldFlip)
   {
      // Flip the Core Graphics Y-axis for future drawing
      CGContextTranslateCTM (cgContext, 0, height);
      CGContextScaleCTM (cgContext, 1.0, -1.0);
   }
   
   // Draw the loaded image into the Core Graphics context 
   // resizing as necessary
   CGContextDrawImage(cgContext, CGRectMake(0, 0, width, height),
      cgImage);
   
   /*****
   {  
      CGImageRef debugImageRef = CGBitmapContextCreateImage(
         cgContext);
      NSLog(@"%p", debugImageRef);
      [[[[[NSBitmapImageRep alloc] initWithCGImage:debugImageRef] 
         autorelease] TIFFRepresentation]
         writeToFile:[@"~/debug.tiff" stringByExpandingTildeInPath] 
         atomically:YES];
      CGImageRelease(debugImageRef);
   }
   *****/
   
   CGContextRelease(cgContext);
   
   *widthPtr = width;
   *heightPtr = height;
   
   return imageData;
}


/////////////////////////////////////////////////////////////////
// This function calculates and returns the nearest power of 2 
// that is greater than or equal to the dimension argument and 
// less than or equal to 2048.
static UtilityPowerOf2 UtilityCalculatePowerOf2ForDimension(
   size_t dimension)
{
   UtilityPowerOf2  result = Utility1;
   
   if(dimension > (size_t)Utility1024)
   {
      result = Utility2048;
   }
   else if(dimension > (size_t)Utility512)
   {
      result = Utility1024;
   }
   else if(dimension > (size_t)Utility256)
   {
      result = Utility512;
   }
   else if(dimension > (size_t)Utility128)
   {
      result = Utility256;
   }
   else if(dimension > (size_t)Utility64)
   {
      result = Utility128;
   }
   else if(dimension > (size_t)Utility32)
   {
      result = Utility64;
   }
   else if(dimension > (size_t)Utility16)
   {
      result = Utility32;
   }
   else if(dimension > (size_t)Utility8)
   {
      result = Utility16;
   }
   else if(dimension > (size_t)Utility4)
   {
      result = Utility8;
   }
   else if(dimension > (size_t)Utility2)
   {
      result = Utility4;
   }
   else if(dimension > (size_t)Utility1)
   {
      result = Utility2;
   }
   
   return result;
}
