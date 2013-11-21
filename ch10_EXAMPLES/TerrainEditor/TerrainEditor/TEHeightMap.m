//
//  TEHeightMap.m
//  TerrainViewer
//

#import "TEHeightMap.h"

@interface TEHeightMap ()

@property (assign, nonatomic, readwrite) NSInteger width;
@property (assign, nonatomic, readwrite) NSInteger length;
@property (strong, nonatomic, readwrite) NSData *heightData;

- (void)loadFromPath:(NSString *)aPath;

@end


@implementation TEHeightMap

@synthesize width;
@synthesize length;
@synthesize heightData;

/////////////////////////////////////////////////////////////////
//  
static const NSInteger TEHeightMapDefaultWidth = 320;
static const NSInteger TEHeightMapDefaultLength = 320;

/////////////////////////////////////////////////////////////////
// 
- (id)init;
{
   if(nil != (self = [super init]))
   {
      self.width = TEHeightMapDefaultWidth;
      self.length = TEHeightMapDefaultLength;
      self.heightData = [NSMutableData dataWithLength:
         self.width * self.length * 1];
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// Designated Initializer 
- (id)initFromPath:(NSString *)aPath;
{
   self = [super init];
   if(nil != self)
   {
      [self loadFromPath:aPath];
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//  
- (void)dealloc
{
   self.heightData = nil;
      
   [super dealloc];
}


/////////////////////////////////////////////////////////////////
//  
- (void)loadFromPath:(NSString *)aPath;
{
   NSImage *image = 
      [[[NSImage alloc] initWithContentsOfFile:aPath] 
      autorelease];
   NSAssert(nil != image, 
      @"Unable to load image at path:%@", aPath);
   CGImageRef cgImage = [image CGImageForProposedRect:NULL 
      context:nil 
      hints:nil];
      
   self.width = CGImageGetWidth(cgImage);
   self.length = CGImageGetWidth(cgImage);
   NSAssert(0 < self.width && 0 < self.length, 
      @"Invalid image dimensions");

   NSMutableData    *imageData = [NSMutableData dataWithLength:
      self.width * self.length * 1];  // 1 byte per gray pixel
   NSAssert(nil != imageData, 
      @"Unable to allocate image storage");

   CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(
      kCGColorSpaceGenericGray);
   CGContextRef cgContext = CGBitmapContextCreate( 
      [imageData mutableBytes], self.width, self.length, 8, 
      1 * width, colorSpace, 
      kCGImageAlphaNone);
   CGColorSpaceRelease(colorSpace);
   
   // Draw the loaded image into the Core Graphics context 
   // resizing as necessary
   CGContextDrawImage(cgContext, 
      CGRectMake(0, 0, self.width, self.length),
      cgImage);

   self.heightData = imageData;
   
   CGContextRelease(cgContext);
}


/////////////////////////////////////////////////////////////////
//  
- (BOOL)isValid
{
   return ((0 < self.width) && (0 < self.length) && 
      (nil != self.heightData));
}


/////////////////////////////////////////////////////////////////
//  
- (GLfloat)heightAtXPos:(short int)x yPos:(short int)y;
{
   GLfloat result = 0;
   
   NSAssert([self isValid], @"Invalid image");
   
   if(x < width && y < length && 0 <= x && 0 <= y)
   {
      unsigned char height = 
         ((unsigned char *)[heightData bytes])[y * width + x];
         
      result = (float)height / 255.0f;
   }
   
   return result;
}

@end
